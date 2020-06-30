let colors = [];
let stop_frame_count = 5;
function setup() {
    createCanvas(1000, 800);
    frameRate(5);
}

function draw() {
    strokeWeight(0.5);
    line(0, 5, 100, 100);  

    if(frameCount > stop_frame_count){
        noLoop();
    }
}
