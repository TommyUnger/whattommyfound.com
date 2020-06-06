let lines = [];
let shapes = [];
let old_sections = [];
let edges = [];
let colors = [];
let stop_frame_count = 5;
let depth = 1;
let side_count = 3;
let rotate = 1/side_count;
function setup() {
    createCanvas(1000, 800);
    frameRate(5);
    colors = [
      [255, 116, 0],
      [240, 15, 146],
      [255, 215, 16],
    ];
    
    // let s = new Shape(new Point(80, 380), 3, -PI/6, 730, 1);
    let s = new Shape(new Point(80, 380), side_count, -PI/6, 730, 1);
    shapes.push(s);
    s.sections.forEach(function(sides){
        sides.forEach(function(line){
        old_sections.push(line);
      })
    })
}

function draw() {
    depth += 1;
    console.log("frame: " + frameCount + "  shapes: " + shapes.length, "  sections: " + old_sections.length);
    let shape_num = 0;
    shapes.forEach(function(s){
        let s1 = new Shape(s.p, s.side_num, s.angle, s.len, 
                           color(255, 128, 0, frameCount*30));
        let cc = colors[frameCount%3];
        s1.c = color(cc[0], cc[1], cc[2], 50+frameCount*20);
        s1.sketchLines();
        shape_num += 1;
    })
    shapes = [];
    new_sections = [];

    old_sections.forEach(function(section){
      if(section.pos == LinePos.INSIDE){
          let newShape = new Shape(section.p1, side_count, section.angle-PI*rotate, section.len, depth);
          shapes.push(newShape);
          for(let side_num=0; side_num<=1; side_num++){
            newShape.sides[side_num].getSections().forEach(function(newSection){
              new_sections.push(newSection);
              if(frameCount==stop_frame_count){
                edges.push(newSection);
              }
            })
          }
        }else{
            section.getSections().forEach(function(newSection){
                new_sections.push(newSection);
                if(frameCount==stop_frame_count){
                  edges.push(newSection);
                }
            })
        }
    })
    old_sections = new_sections;

    if(frameCount > stop_frame_count){
      let cc = color(255, 128, 0, 250);
      edges.forEach(function(e){
          e.render(cc);
        })
        noLoop();
    }
}
