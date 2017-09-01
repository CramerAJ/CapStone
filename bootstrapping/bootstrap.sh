#! /usr/bin/env bash
if [ -d /vagrant ]
  then
    ENV_USER=vagrant

    sudo rm -rf /var/www
    sudo ln -s /vagrant/www /var/www

  else
    sudo rm -rf /var/www
    sudo mkdir /var/www
    ENV_USER=ubuntu
fi

# define env variables:
DB_HOST=staging.vetro.io
META_DB=vetro_fibermap
CLIENT_DB=gwi
DB_PASSWORD=7AcHubr@nbt
DB_USER=geo
PG_PASS='a*7b()nbt'

echo -e "\n######## Starting bootstrap process ########\n"
echo -e "\n######## running apt-get update... ########\n"
sudo apt-get update

echo -e "\n######## install 1GB swap... ########\n"
# create the swapfile and set perms:
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
# tell mem management to use that file for swap:
sudo mkswap /swapfile
sudo swapon /swapfile
printf "/swapfile   none    swap    sw    0   0\n" | sudo tee -a /etc/fstab
# set "swappiness" - basically whether it should be used as last resort or not
sudo sysctl vm.swappiness=10
printf "\nvm.swappiness=10\n" | sudo tee -a /etc/sysctl.conf
# how fast should we be clearing inode info from the cache?
sudo sysctl vm.vfs_cache_pressure=50
printf "vm.vfs_cache_pressure=50\n" | sudo tee -a /etc/sysctl.conf
sudo swapon -s

echo -e "\n######## installing some tools... ########\n"
# tools
sudo apt-get -y install unzip
sudo apt-get -y install curl
sudo apt-get -y install vim
sudo apt-get -y install git
sudo apt-get -y install openjdk-7-jre
sudo apt-get -y install libreoffice-calc

git config --global url."https://".insteadOf git://

echo -e "\n######## install redis... ########\n"
sudo apt-add-repository -y ppa:chris-lea/redis-server
sudo apt-get -y install redis-server redis-tools

echo -e "\n######## setting up postgres apt repo... ########\n"
# setup postgres/gis
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list'
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
echo -e "\n######## installing Postgresql-9.4-postgis and postgresql-contrib... ########\n"
sudo apt-get -y install Postgresql-9.4-postgis-2.2-scripts postgresql-contrib

echo -e "\n######## starting to create the postgis extension... ########\n"
sudo -u postgres psql -c "CREATE EXTENSION postgis;"
sudo -u postgres psql -c "CREATE EXTENSION postgis_topology;"

echo -e "\n######## installing a bunch of postgres stuff: ########\n"
echo -e "\n######## installing postgresql-client-common: ########\n"
# install a bunch of postgres stuff
sudo apt-get -y install postgresql-client-common
echo -e "\n######## installing postgresql-client-9: ########\n"
sudo apt-get -y install postgresql-client-9.4
echo -e "\n######## installing python-software-properties: ########\n"
sudo apt-get -y install python-software-properties
echo -e "\n######## adding apt-get repo ubuntugus and georepublic: ########\n"
sudo add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
sudo add-apt-repository -y ppa:georepublic/pgrouting

echo -e "\n######## installing postgresql-9.4-pgrouting: ########\n"
sudo apt-get -y install postgresql-9.4-pgrouting

echo -e "\n######## creating databases and users... ########\n"
# create vetro databases and user

# echo -n "Please type the host domain to pull from then press [ENTER]: "
# read DB_HOST
# echo -n "Please type the name of the meta database then press [ENTER]: "
# read META_DB
# echo -n "Please type the name of the client database then press [ENTER]: "
# read CLIENT_DB
# echo -n "Please type the username then press [ENTER]: "
# read DB_USER
# echo -n "Please type the password then press [ENTER]: "
# read DB_PASSWORD

sudo -u postgres psql -c "CREATE DATABASE ${META_DB};";
sudo -u postgres psql -c "CREATE DATABASE ${CLIENT_DB};";
sudo -u postgres psql -c "CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';";
sudo -u postgres psql -c "ALTER USER ${DB_USER} CREATEDB;";
sudo -u postgres psql -c "ALTER user postgres WITH PASSWORD '${PG_PASS}'"

sudo -u postgres psql -c "GRANT ALL PRIVILEGES on DATABASE ${META_DB} to ${DB_USER};"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES on DATABASE ${CLIENT_DB} to ${DB_USER};"

echo -e "\n######## .pgpass file for permissions... ########\n"
cp /vagrant/bootstrapping/.pgpass ~/

# cat > ~/.pgpass <<EOF
# ${DB_HOST}:*:*:${DB_USER}:${DB_PASSWORD}
# localhost:*:*:${DB_USER}:${DB_PASSWORD}
# EOF

chmod 600 ~/.pgpass


echo -e "\n######## importing current version of staging database... ########\n"
pg_dump -h ${DB_HOST} -U postgres -w ${CLIENT_DB} | sudo -u postgres psql -d ${CLIENT_DB}
pg_dump -h ${DB_HOST} -U postgres -w ${META_DB} | sudo -u postgres psql -d ${META_DB}

# original came from: https://gist.github.com/gingerlime/2482969
for tbl in `sudo -u postgres psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" ${META_DB}` \
           `sudo -u postgres psql -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" ${META_DB}` \
           `sudo -u postgres psql -qAt -c "select table_name from information_schema.views where table_schema = 'public';" ${META_DB}` ;
do
    sudo -u postgres psql -c "alter table \"$tbl\" owner to ${DB_USER}" ${META_DB} ;
done

# And do it again for the other DB:
for tbl in `sudo -u postgres psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" ${CLIENT_DB}` \
           `sudo -u postgres psql -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" ${CLIENT_DB}` \
           `sudo -u postgres psql -qAt -c "select table_name from information_schema.views where table_schema = 'public';" ${CLIENT_DB}` ;
do
    sudo -u postgres psql -c "alter table \"$tbl\" owner to ${DB_USER}" ${CLIENT_DB} ;
done

echo -e "\n######## copying database files... ########\n"

cp /vagrant/bootstrapping/pg_hba.conf /etc/postgresql/9.4/main/
cp /vagrant/bootstrapping/postgresql.conf /etc/postgresql/9.4/main/

echo -e "\n######## restarting postgresql... ########\n"
sudo service postgresql restart

echo -e "\n######## install nginx... ########\n"
# we'll use nginx to do our internal app routing with port forwarding
sudo apt-get -y install nginx

echo -e "\n######## configuring nginx... ########\n"
sudo cp /vagrant/bootstrapping/nodeserver_nginx.conf /etc/nginx/sites-available/
sudo rm /etc/nginx/sites-enabled/default

sudo ln -s /etc/nginx/sites-available/nodeserver_nginx.conf /etc/nginx/sites-enabled/nodeserver_nginx.conf

echo -e "\n######## restarting nginx... ########\n"
sudo service nginx start

echo -e "\n######## install nodejs... ########\n"
sudo apt-get install -y nodejs
sudo apt-get install -y npm

echo "### Upgrade Node to newest version: ###"
sudo npm cache clean -f
sudo npm install -g n
sudo n stable

echo -e "\n######## set npm registry... ########\n"
sudo npm config set registry http://registry.npmjs.org/

cd /vagrant/www

sudo npm install
sudo npm install -g supervisor
sudo npm install -g bower
sudo npm install -g grunt grunt-cli
sudo npm install -g phantomjs

echo -e "\n######## install upstart... ########\n"
# For running node server perpetually, after restarting
sudo apt-get install -y upstart

echo -e "\n######## configure daemon script... ########\n"
sudo cp /vagrant/bootstrapping/nodeserver.conf /etc/init/
sudo chmod 777 /etc/init/nodeserver.conf

echo -e "\n######## install monit... ########\n"
# install monit and copy conf file over
sudo apt-get install -y monit

echo -e "\n######## configure monit... ########\n"
sudo cp /vagrant/bootstrapping/nodeserver_monit.conf /etc/monit/conf.d/
sudo chmod 700 /etc/monit/conf.d/nodeserver_monit.conf

echo -e "\n######## start up the nodejs daemon... ########\n"
# start the node server daemon
sudo start nodeserver

echo -e "\n######## start up monit... ########\n"
# start monit for error checking
sudo monit -d 10 -c /etc/monit/conf.d/nodeserver_monit.conf
sudo service nginx reload

echo -e "\n######## All done! ########\n"
