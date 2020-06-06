// a few global variables.
var map;
var colors = ['#e7e1ef','#d4b9da','#c994c7','#df65b0','#e7298a','#ce1256','#91003f','#91003f'];
var minute_points = {}


// helper function to get array in Google lat/lng form.
function points_to_lat_lngs(pts){
    var lls = [];
    pts.forEach(function(pt){
        lls.push({"lat": pt[0], "lng": pt[1]})
    })
    return lls;
}


// distince in kilometers between two points.
function dist(pt1, pt2){
    return turf.distance([pt1.lng, pt1.lat], 
                         [pt2.lng, pt2.lat], 
                         {units: 'kilometers'}) * 1000
}

// Displays a commute route on Google maps, with time-based coloring
// Currently, the colors are 10 minute buckets.
// Sets up arrays of all points for layering in polygons
function show_route(rt){
    var last_pt = null;
    var path_groups = {};
    var total_time = 0;
    // deep nesting of loops and conditionals because of geo complexity
    rt.routes.forEach(function(route){
        route.legs.forEach(function(leg){
            leg.steps.forEach(function(step){
                var meters_per_second = step.distance.value / (step.duration.value);
                var pts = points_to_lat_lngs(step.polyline.points);
                pts.forEach(function(pt){
                    if(last_pt != null){
                        total_time += dist(pt, last_pt) / meters_per_second;
                        // 10 minute buckets.
                        var minute_bucket = 10 * Math.floor(total_time / 600);
                        if(!(minute_bucket in path_groups)){
                            path_groups[minute_bucket] = [last_pt];
                        }
                        if(!(minute_bucket in minute_points)){
                          minute_points[minute_bucket] = [turf.point([last_pt.lng, last_pt.lat])]
                        }
                        // only showing up to 70 minute commutes.
                        if(minute_bucket <= 70){
                          path_groups[minute_bucket].push(pt);
                          // Sampling 10% of points to speed things up a bit.
                          if(Math.random() < 0.1){
                            minute_points[minute_bucket].push(turf.point([pt.lng, pt.lat]));
                          }
                        }
                    }
                    last_pt = pt;
                })

            })
        })
    })

    // Draw the paths, one 10-minute group at a time
    for(var minutes in path_groups){
        var pts = path_groups[minutes];
        var the_path = new google.maps.Polyline({
            path: pts,
            geodesic: true,
            strokeColor: colors[Math.floor(minutes / 10.0)],
            strokeOpacity: 1.0,
            strokeWeight: 5
        });
        the_path.setMap(map);
    }
}


function initMap() {
    show_poly = true;
    map = new google.maps.Map(d3.select("#map").node(), {
        zoom: 11,
        center: new google.maps.LatLng(47.6101, -122.3375),
        mapTypeId: google.maps.MapTypeId.TERRAIN,
        // I can't beleive the complexity of doing a dark background.
        styles: [
            {elementType: 'geometry', stylers: [{color: '#242f3e'}]},
            {elementType: 'labels.text.stroke', stylers: [{color: '#242f3e'}]},
            {elementType: 'labels.text.fill', stylers: [{color: '#746855'}]},
            {
              featureType: 'administrative.locality',
              elementType: 'labels.text.fill',
              stylers: [{color: '#d59563'}]
            },
            {
              featureType: 'poi',
              elementType: 'labels.text.fill',
              stylers: [{color: '#d59563'}]
            },
            {
              featureType: 'poi.park',
              elementType: 'geometry',
              stylers: [{color: '#263c3f'}]
            },
            {
              featureType: 'poi.park',
              elementType: 'labels.text.fill',
              stylers: [{color: '#6b9a76'}]
            },
            {
              featureType: 'road',
              elementType: 'geometry',
              stylers: [{color: '#38414e'}]
            },
            {
              featureType: 'road',
              elementType: 'geometry.stroke',
              stylers: [{color: '#212a37'}]
            },
            {
              featureType: 'road',
              elementType: 'labels.text.fill',
              stylers: [{color: '#9ca5b3'}]
            },
            {
              featureType: 'road.highway',
              elementType: 'geometry',
              stylers: [{color: '#746855'}]
            },
            {
              featureType: 'road.highway',
              elementType: 'geometry.stroke',
              stylers: [{color: '#1f2835'}]
            },
            {
              featureType: 'road.highway',
              elementType: 'labels.text.fill',
              stylers: [{color: '#f3d19c'}]
            },
            {
              featureType: 'transit',
              elementType: 'geometry',
              stylers: [{color: '#2f3948'}]
            },
            {
              featureType: 'transit.station',
              elementType: 'labels.text.fill',
              stylers: [{color: '#d59563'}]
            },
            {
              featureType: 'water',
              elementType: 'geometry',
              stylers: [{color: '#17263c'}]
            },
            {
              featureType: 'water',
              elementType: 'labels.text.fill',
              stylers: [{color: '#515c6d'}]
            },
            {
              featureType: 'water',
              elementType: 'labels.text.stroke',
              stylers: [{color: '#17263c'}]
            }
          ]
    });

    // get the locations json, originally from Redfin
    d3.json("locations.json")
      .then(function(json) {
          // this was easy
          json.forEach(function(route){
            show_route(route);
          })

          // but then I tried to get fancy
          var bounds = map.getBounds();
          var p1 = bounds.getNorthEast();
          var p2 = bounds.getSouthWest();

          var w = map.getDiv().offsetWidth;
          var h = map.getDiv().offsetHeight;

          var svg = d3.select('svg')
            .attr('width', w)
            .attr('height', h);

          var x = d3.scaleLinear()
              .range([w, 0])
              .domain([p1.lng(), p2.lng()]);

          var y = d3.scaleLinear()
              .range([0, h])
              .domain([p1.lat(), p2.lat()]);


          var svg = d3.select("#map .gm-style")
                .append("svg")
                .attr("class", "overlay");

          d3.select("#info")
            .insert("div")
            .attr("class", "show poly")
            .text("Toggle polygons")
            .on("mousedown", function(){
              var active = !show_poly;
              var display = 0;
              if(active){
                display = 1;
              }
              svg.selectAll("polygon.p").style("opacity", display);
              show_poly = active;
            });

          var all_points = [];
          for(var minutes in minute_points){
            all_points = all_points.concat(minute_points[minutes]);
            var points = turf.featureCollection(all_points);
            var hull = turf.concave(points, {units: 'miles', maxEdge: 4});
            hull = turf.buffer(hull, 0.5, {units: 'miles'});
            if(hull == null){
              continue;
            }

            if(hull.geometry.type == "Polygon"){
              shapes = [hull.geometry.coordinates[0]]
            }else{
              shapes = hull.geometry.coordinates[0];
            }
            svg.selectAll("polygon.m" + minutes)
              .data(shapes)
            .enter().insert("polygon")
              .attr("points",function(d) {
                  return d.map(function(d) {
                    return [x(d[0]), y(d[1])].join(",");
                  }).join(" ");
              })
              .attr("stroke", colors[minutes/10])
              .attr("stroke-width",2)
              .attr("fill", colors[minutes/10])
              .attr("fill-opacity", 0.1)
              .attr("class", "p m" + minutes);
          }



        })

}


