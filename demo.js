/**
 * Created by ACramer on 5/3/18.
 */

let firstNames = ['Carl','Andrew','Aly','Matt','Dave','Jason','Tyler','Howard','Lise','Evan','Dennis','Samantha','Sam','Kelly','Chris','Mark','Jess','Jessica','Rebbeca','Rob','Derik'];
let lastNames = ['Johnson','Turner','Cramer','Davidson','Adams','Person','Spice','Kenny','Milk','Evans','Stephenson','Kramer','Kraemer','Robertson','Jameson'];
let weather = ['Flooding','Fire','Electrical'];
let allUsersDemo = L.layerGroup([]);
function demo() {


    let rndCoordinates = function (from, to, fixed) {
        return (Math.random() * (to - from) + from).toFixed(fixed) * 1;
    };

    function randomNames(firstNames,lastNames){
        return firstNames [Math.floor(Math.random()*firstNames.length)];
        return lastNames [Math.floor(Math.random()*lastNames.length)];

    }
    function randomDisaster(weather){
        return weather [Math.floor(Math.random())];
    }

    for (let i = 0; i <= 100; i++) {

        let geo = [rndCoordinates(44.89408017877255,44.90458303369733 , 7), rndCoordinates(-68.65856075499325, -68.67403173659115, 7)];

        L.marker(geo).bindPopup(
            "User: "+randomNames(firstNames)+ ' '+randomNames(lastNames)
            +'<br>'+'Building Status:'+ ''+checkedLocation+ '<br>'
            +'<br>'+'Weather Type:'+ randomDisaster(weather)+ '<br>'
            +'<br>'+'Pictures:'
        ).addTo(map).addTo(allUsersDemo);

        if (i === 100){


            let testIndex = otherUsers.getLayers();
            let latLngArrayList = [];
            for (let j = 0; j <= testIndex.length; j++){

                let firstIndexPoint = testIndex[j]._latlng;
                console.log(firstIndexPoint+'first index');

                latLngArrayList.push(firstIndexPoint);

                if (j === 100){

                    for ( let k = 0; k <= latLngArrayList.length; k++){
                        let pointA = latLngArrayList[k];

                        for (let m = 0; m<= latLngArrayList.length; m++){
                            let pointB = latLngArrayList[m];

                               if (distance(pointA,pointB) <= 150){

                                   console.log('within 150 feet');
                               }
                               else {
                                   console.log('NOPE');
                               }
                        }
                    }
                }
            }
        }

    }

}