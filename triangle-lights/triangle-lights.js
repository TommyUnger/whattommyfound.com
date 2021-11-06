// planet class
let TWOPI = 2 * Math.PI;

function t_triangle(x, y, sz, angle, scale) {
    this.x = x;
    this.y = y;
    this.sz = sz;
    this.angle = angle;
    this.el = null;
    this.points = null;
    this.scale = scale;
    this.inner_points = null;

    this.getPointList = function(){
        console.log("WTF");
        return this.points;
    }

    this.getPoints = function(){
        this.points = [[this.x, this.y]];
        for(var theta = -PI / 6; theta <= PI / 6; theta += PI / 3){
            this.points.push([
                this.x - sz * Math.sin(this.angle + theta),
                this.y - sz * Math.cos(this.angle + theta),
            ])
        }
        var small_x = this.x - (sz*(1-this.scale)/(2*Math.sin(PI / 3))) * Math.sin(this.angle);
        var small_y = this.y - (sz*(1-this.scale)/(2*Math.sin(PI / 3))) * Math.cos(this.angle);
        this.inner_points = [[small_x, small_y]];
        for(var theta = -PI / 6; theta <= PI / 6; theta += PI / 3){
            this.inner_points.push([
                small_x - (sz*this.scale) * Math.sin(this.angle + theta),
                small_y - (sz*this.scale) * Math.cos(this.angle + theta),
            ])
        }

        return {
              "outer":
               this.points[0][0] + "," + this.points[0][1] + " " + 
               this.points[1][0] + "," + this.points[1][1] + " " + 
               this.points[2][0] + "," + this.points[2][1],
               "inner":
               this.inner_points[0][0] + "," + this.inner_points[0][1] + " " + 
               this.inner_points[1][0] + "," + this.inner_points[1][1] + " " + 
               this.inner_points[2][0] + "," + this.inner_points[2][1]
        }
    }

    this.display = function() {
        this.el = svg.append('polygon')
                     .attr('points', this.getPoints()["inner"])
    };
}

let triangles = {};
let svg = null;
let PI = Math.PI;

function setup_triangles() {
    console.log("setup");
    svg = d3.select("#triangles");
    let sz = 140;
    let x = 300;
    let y = 150;
    let scale = 0.7;

    for(var i = 0; i < 6; i++){
        var tri = new t_triangle(x, y, sz, 2 * i * PI / 6, scale);
        console.log(tri.getPointList());
    }
    y += sz * Math.cos(PI/6);
    x += sz * Math.sin(PI/6);
    for(var i = 0; i < 6; i++){
        var tri = new t_triangle(x, y, sz, 2 * i * PI / 6, scale);
    }
    x -= 2 * sz * Math.sin(PI/6);
    for(var i = 0; i < 6; i++){
        var tri = new t_triangle(x, y, sz, 2 * i * PI / 6, scale);
    }
    console.log(triangles)
    Object.values(triangles).forEach(function(t){
        t.display();
    })
}

setup_triangles();
