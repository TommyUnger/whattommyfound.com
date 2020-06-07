let stop_frame_count = 10;
let w = 1700;
let h = 1000;
let cps = [];
let y = 100;
let proj = null;
let data = [];
let rendered_count = 0;
let states = {};

function rand1(num){
    return Math.random() * num - num / 2;
}

let counties = {};
let covid_data = null;

function setup() {
    d3.csv("county-summary.csv").then(function(county_summary) {
        county_summary.forEach(function(d){
            d.population_gt_44 = +d.population_gt_44;
            d.lon = +d.lon;
            d.lat = +d.lat;
            counties[+d.fips] = d;
        })

        d3.csv("county-covid-details.csv").then(function(county_data) {
            county_data.forEach(function(d){
                d.cases = +d.cases;
                d.deaths = +d.deaths;
                if(!(+d.fips in counties)){

                }else{
                    d.cases_per_1000 = 1000 * d.cases / counties[+d.fips].population_gt_44;
                    d.deaths_per_100000 = 100000 * d.cases / counties[+d.fips].population_gt_44;
                }
            })
            covid_data = d3.nest()
                .key(function(d) { return d.date; })
                .entries(county_data);
        });
    });

    d3.json("us-states.json").then(function(loaded_states) {
        states = loaded_states;
    });

    createCanvas(w, h, WEBGL);
    frameRate(5);
    proj = d3.geoAlbersUsa()
                   .translate([0, 0])
                   .scale([w*0.9]);     
}

function draw() {
    let selected = covid_data.length - 6;
    if(covid_data[selected].values.length >= 10){
        translate(-100, -250);
        rotateX(PI/6);
        stroke(color(200, 200, 200, 150));
        states.features.forEach(function(st){
            console.log(st.geometry.type);
            st.geometry.coordinates.forEach(function(c, i1){
                let arr = c;
                if(st.geometry.type == "Polygon"){
                    arr = [c];
                }
                arr = arr[0];
                arr.forEach(function(coord, i2){
                    let p0 = proj([coord[0], coord[1]]);
                    let p1 = proj([arr[(i2+1)%arr.length][0], arr[(i2+1)%arr.length][1]]);
                    if(p0 && p1){
                        line(p0[0], p0[1], p1[0], p1[1]);
                    }
                })
            })
        })

        strokeWeight(2);
        stroke(color(255, 80, 70, 255));
        covid_data[selected].values.forEach(function(d){
            if(!(+d.fips in counties)){
                return;
            };
            let p = proj([counties[+d.fips].lon, counties[+d.fips].lat]);
            line(p[0], p[1], 0, p[0], p[1], d.cases_per_1000*0.7);
            rendered_count += 1;
        })
        data = [];
        noLoop();
    }
    if(frameCount > stop_frame_count){
        noLoop();
    }
}



