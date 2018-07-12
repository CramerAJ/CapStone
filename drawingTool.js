/**
 * Created by ACramer on 5/3/18.
 */
//This code is a collection of drawing tools, part of my original concept, some code is missing, but the majority
//will create a drawing option tool
//Drawing Features being created
//Testing Zoom here with alot of markers on a screen at one time
   map.on(L.Draw.Event.CREATED, function (e) {

       let type = e.layerType;
       let layer = e.layer;
       // Do whatever else you need to. (save to db, add to map etc)

       floodItems.addLayer(layer);
       fireItems.addLayer(layer);
       electricalItems.addLayer(layer);

       console.log('floodPolygon')
   });

//Testing grabbing the user location at different time increments
//
// setInterval(polygonCreation,10000);
//
//    function polygonCreation(){
//        console.log("checking for similar marker types");
//    }
//     map.on('click',
//     	function(e){
//     		let coord = e.latlng.toString().split(',');
//     		let lat = coord[0].split('(');
//     		let lng = coord[1].split(')');
//     		L.marker(e.latlng).addTo(map);
//
//     		console.log(L.marker(e.latlng));
//     	});




   let floodItems = new L.FeatureGroup();
   // Initialise the draw control and pass it the FeatureGroup of editable layers
   let floodControl = new L.Control.Draw({
       draw: {
           polyline: {
               shapeOptions: {
                   color: '#2373dc',
                   weight: 10
               }
           },
           polygon: {
               allowIntersection: false, // Restricts shapes to simple polygons
               drawError: {
                   color: '#2373dc', // Color the shape will turn when intersects
                   message: 'you can\'t draw that!' // Message that will show when intersect
               },
               shapeOptions: {
                   color: '#2373dc'
               }
           },
           circle: false, // Turns off this drawing tool
           rectangle: {
               shapeOptions: {
                   clickable: false,
                   color: "#2373dc"
               }
           }
       },

       edit: {
           featureGroup: floodItems
       }
   });    let fireItems = new L.FeatureGroup();
   // Initialise the draw control and pass it the FeatureGroup of editable layers
   let fireControl = new L.Control.Draw({
       draw: {
           polyline: {
               shapeOptions: {
                   color: '#a80009',
                   weight: 10
               }
           },
           polygon: {
               allowIntersection: false, // Restricts shapes to simple polygons
               drawError: {
                   color: '#a80009', // Color the shape will turn when intersects
                   message: 'you can\'t draw that!' // Message that will show when intersect
               },
               shapeOptions: {
                   color: '#a80009'
               }
           },
           circle: false, // Turns off this drawing tool
           rectangle: {
               shapeOptions: {
                   clickable: false,
                   color: "#a80009"
               }
           }
       },

       edit: {
           featureGroup: fireItems
       }
   });
   let electricalItems = new L.FeatureGroup();
   // Initialise the draw control and pass it the FeatureGroup of editable layers
   let electriclControl = new L.Control.Draw({
       draw: {
           polyline: {
               shapeOptions: {
                   color: '#cfd000',
                   weight: 10
               }
           },
           polygon: {
               allowIntersection: false, // Restricts shapes to simple polygons
               drawError: {
                   color: '#cfd000', // Color the shape will turn when intersects
                   message: 'you can\'t draw that!' // Message that will show when intersect
               },
               shapeOptions: {
                   color: '#cfd000'
               }
           },
           circle: false, // Turns off this drawing tool
           rectangle: {
               shapeOptions: {
                   clickable: false,
                   color: "#cfd000"
               }
           }
       },

       edit: {
           featureGroup: electricalItems
       }
   });

   map.on(L.Draw.Event.CREATED, function (e) {
       let type = e.layerType;
       let layer = e.layer;
       // Do whatever else you need to. (save to db, add to map etc)
       floodItems.addLayer(layer);
       console.log(e.layer);
       console.log('drawingPolygon')
   });
   let labelCount = 1;
   //Call made to display the tools in the UI
   function PopUp() {
       if (labelCount===1) {
           // Initialise the FeatureGroup to store editable layers
           map.addLayer(floodItems);
           map.addControl(floodControl);
           labelCount++;
       }
       else {
           map.removeControl(floodControl);
           map.removeControl(floodItems);
           labelCount--;
       }
   }

    function PopUpRed() {
        if (labelCount===1) {
            // Initialise the FeatureGroup to store editable layers
            map.addLayer(fireItems);
            map.addControl(fireControl);
            map.addLayer(electricalItems);
            map.addControl(electriclControl);
            labelCount++;
        }
        else {
            map.removeControl(fireControl);
            map.removeControl(fireItems);
            labelCount--;
        }
    }

