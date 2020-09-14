let planets = [];
let sun = {"x":400, "y":380};
let bg;
let scale = 0.6;
let planet_scale = 0.6;
let asteroid_belt;

function preload(){
}

function setup() {
    bg = color(20, 10, 10);
    createCanvas(800, 700);
    frameRate(60);
    planets.push(new planet(1.5, 4, 3.7, [255, 20, 0, 250]));
    planets.push(new planet(3.7, 7, 8.9, [235, 235, 20, 250]));
    planets.push(new planet(3.9, 10, 9.9, [60, 50, 250, 250]));
    planets.push(new planet(2.1, 15, 3.7, [235, 0, 0, 250]));

    planets.push(new planet(43, 52, 23.1, [200, 80, 60, 250]));
    planets.push(new planet(36, 96, 9.0, [235, 168, 100, 250]));
    planets.push(new planet(15.7, 192, 8.7, [150, 208, 150, 250]));
    planets.push(new planet(15.2, 300, 11.0, [110, 120, 220, 250]));
    asteroid_belt = new asteroids(30);
}

function draw() {
    if(keyIsDown(40)){
        scale = scale * 1.03;
    }else if(keyIsDown(38)){
        scale = scale / 1.03;
    }
    background(bg); 
    for(let p of planets){
        p.update();
        p.display();
    }
    asteroid_belt.display();
}

function asteroids(h_radius){
    this.angle = 0;
    this.asteroids = [];
    for(let i=0; i < 100; i++){
        this.asteroids.push(new asteroid(h_radius));
    }
    this.display = function(){
        for(let a of this.asteroids){
            a.update();
            a.display();
        }
    }
}

function asteroid(h_radius){
    this.x = 0;
    this.y = 0;
    this.h_radius = h_radius*(0.8+random()*0.4);
    this.pos_angle = 2*PI*random();
    this.a = 0.5 + 2 * random();
    this.b = 0.5 + 2 * random();
    this.op = 80+random()*160;

    this.update = function(){
        this.pos_angle += sqrt(0.1 * 2 / (this.h_radius)) / sqrt(this.h_radius * scale)
        this.x = sun.x + this.h_radius * cos(this.pos_angle) * scale;
        this.y = sun.y + this.h_radius * sin(this.pos_angle) * scale;
    }

    this.display = function(){
        noStroke();
        fill(200, 100, 50, this.op);
        ellipse(this.x, this.y, this.a*(scale>3?3:scale), this.b*(scale>3?3:scale));
    }
}

// planet class
function planet(radius, h_radius, g, color) {
    this.radius = radius;
    this.h_radius = h_radius;
    this.w_radius = h_radius*(1+random()*0.05);
    this.pos_angle = 2*PI*random();
    this.x = null;
    this.y = null;
    this.c = color;
    this.g = g;

    this.update = function(){
        this.pos_angle += sqrt(0.1 * this.g / (this.h_radius)) / sqrt(this.h_radius * scale);
        this.x = sun.x + this.w_radius * cos(this.pos_angle) * scale;
        this.y = sun.y + this.h_radius * sin(this.pos_angle) * scale;
    }

    this.display = function() {
        noFill();
        stroke(255, 255, 255, 30);
        strokeWeight(2);
        ellipse(sun.x, sun.y, this.w_radius*2*scale, this.h_radius*2*scale);

        noStroke();
        fill(this.c);
        circle(this.x, this.y, this.radius*planet_scale*scale);
    };
    
}

