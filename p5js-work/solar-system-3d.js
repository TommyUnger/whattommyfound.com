let planets = [];
let sun = {"x":400, "y":380};
let bg;
let scale = 0;
let planet_scale = 1.6;
let asteroid_belt;

function preload(){
}

function setup() {
    bg = color(20, 10, 10);
    createCanvas(800, 700, WEBGL);
    camera(0, 0, 70, 0, 0, 0, 0, 1, 0);
    frameRate(30);
    planets.push(new planet(1.5, 4, 3.7, [155, 20, 0, 250]));
}

function draw() {
    if(keyIsDown(40)){
        scale = scale + 10;
    }else if(keyIsDown(38)){
        scale = scale - 10;
    }
    background(bg); 
    for(let p of planets){
        p.update();
        p.display();
    }
}


// planet class
function planet(radius, orbit_radius, g, color) {
    this.radius = radius;
    this.h_radius = orbit_radius;
    this.w_radius = orbit_radius*(1+random()*0.05);
    this.pos_angle = 2*PI*random();
    this.x = null;
    this.y = null;
    this.z = 0;
    this.c = color;
    this.g = g;

    this.update = function(){
        this.pos_angle += sqrt(0.1 * this.g / (this.h_radius)) / sqrt(this.h_radius);
        this.x = this.w_radius * cos(this.pos_angle);
        this.y = this.h_radius * sin(this.pos_angle);
    }

    this.display = function() {
        noFill();
        // ellipse(sun.x, sun.y, this.w_radius*2*scale, this.h_radius*2*scale);
        // directionalLight(255, 0, 0, -1000);
        ambientLight(60, 60, 60);
        pointLight(255, 255, 255, 0, 0, 1000);        
        shininess(20);
        stroke(this.c);
        strokeWeight(0.1);
        fill(this.c);
        translate(this.x, this.y, 0);
        rotateX(PI/2)
        sphere(this.radius * planet_scale, 10, 10);
    };
    
}

