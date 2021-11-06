let y = 100;

function setup() {
    // createCanvas must be the first statement
    createCanvas(720, 400);
    stroke(255); // Set line drawing color to white
    frameRate(2);
}

function draw() {
    background(100);
    rainDrop(100, 100, 3);
}

function ra(s){
    return Math.random()*s;
}

function rainDrop(x, y, sz){
    beginShape();
    vertex(x, y);
    w = ra(5) + 10;
    r1 = ra(8)-6;
    bezierVertex(x+10*sz+r1, y+32*sz, x+(w-1)*sz, y+25*sz, x+w*sz, y+40*sz);
    bezierVertex(x+w*sz, y+60*sz, x-w*sz, y+60*sz, x-w*sz, y+40*sz);
    bezierVertex(x-(w-1)*sz, y+25*sz, x-10*sz-r1, y+32*sz, x      , y      );
    endShape();
}