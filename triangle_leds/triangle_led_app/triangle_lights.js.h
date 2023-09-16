#include <pgmspace.h>

#ifndef _TRIANGLE_LIGHTS_JS_
#define _TRIANGLE_LIGHTS_JS_

const char triangle_lights_js[] PROGMEM = R"=====(
let PI = Math.PI
let TWOPI = 2 * PI;
let PI6 = PI / 6;
let PI3 = PI / 3;
let CORNER_IDS = [19,18,20,16,15,17,14,13,12,25,24,26,23,21,22,38,37,36,10,11,9,8,7,6,27,29,28,30,32,31,35,34,33,1,0,2,5,4,3];
let down_tri = null;

function get_current_rgb(){
    return SELECTED_COLOR.getRgbStr();
}

function send_colors_to_tris(){
    var url_colors = [];
    COLORS.forEach(function(el, color_i){
        var ccs = el.selectChild("stop").attr("stop-color").match(/([0-9]+)/gi);
        ccs.forEach(function(c, i){
            ccs[i] = (+c).toString(16).padStart(2, '0');
        })
        url_colors[CORNER_IDS[color_i]] = ccs.join("");
    })
    // console.log(url_colors.join(","));
    var url = "http://192.168.0.47/?colors=" + url_colors.join(",");
    fetch(url, {
        mode: 'no-cors', // It can be no-cors, cors, same-origin
      }).then(returnedData => {
        // Do whatever with returnedData
      }).catch(err => {
        // In case it errors.
      })

}

class Color {
    constructor(h, s, l){
        this.h = h;
        this.s = s;
        this.l = l;
        this.c = d3.hsl(this.h, this.s, this.l);
    }

    getRgbStr(){
        return this.c.formatRgb();
    }

    getStr(){
        return this.c.toString();
    }
}

class Triangle {
    constructor(x, y, SIDE_LEN, angle, tri_num) {
        this.x = x;
        this.y = y;
        this.tri_num = tri_num;
        this.SIDE_LEN = SIDE_LEN;
        this.radius = PI * SIDE_LEN * (Math.cos(PI6) - Math.sin(PI6));
        this.angle = angle;
        this.el = null;
        this.points = null;
        this.colors = [];
    }

    getCenter(){
        return this.x + "," + this.y;
    }

    setPoints(){
        this.points = [];
        for(var theta = this.angle; theta > -TWOPI; theta -= TWOPI / 3){
            this.points.push([
                this.x - this.radius * Math.sin(theta),
                this.y - this.radius * Math.cos(theta),
            ])
        }
    }

    getSvgPoint(n){
        return this.points[n][0] + "," + this.points[n][1];
    }

    showPoly(){
        let t_points = this.getSvgPoint(0) + " " + this.getSvgPoint(1) + " " + this.getSvgPoint(2);
        var corner_num = 0;
        for(var theta = this.angle; theta > -TWOPI; theta -= TWOPI / 3){
            var points = "M " + (this.x - 0.55*this.radius * Math.sin(theta-PI/2)) +
                      " " +     (this.y - 0.55*this.radius * Math.cos(theta-PI/2)) + 
                      " C " +   (this.x - 1.05*this.radius * Math.sin(theta)) + 
                      " " +     (this.y - 1.05*this.radius * Math.cos(theta)) + 
                      "," + (this.x - 1.05*this.radius * Math.sin(theta)) + 
                      " " + (this.y - 1.05*this.radius * Math.cos(theta)) + 
                      "," + (this.x - 0.55*this.radius * Math.sin(theta+PI/2)) + 
                      " " + (this.y - 0.55*this.radius * Math.cos(theta+PI/2)) +
                      " L " + (this.x - this.radius * Math.sin(theta+TWOPI/3)) +
                      " " + (this.y - this.radius * Math.cos(theta+TWOPI/3)) + 
                      " L " + (this.x - this.radius * Math.sin(theta-TWOPI/3)) +
                      " " + (this.y - this.radius * Math.cos(theta-TWOPI/3)) +
                      " L " + (this.x - 0.55*this.radius * Math.sin(theta-PI/2)) +
                      " " +   (this.y - 0.55*this.radius * Math.cos(theta-PI/2))
                      ;
            var grad_id = "grad_" + TRIS.length + "_" + corner_num;
            var dx = Math.round(Math.sin(theta)*100)/100.0;
            var dy = Math.round(Math.cos(theta)*100)/100.0;
            var cx = 0;
            var cy = 0;
            if(dy == 1){
                cy = 0;
                cx = 0.5;
            }
            else if(dy == -1){
                cy = 1;
                cx = 0.5;
            }
            else{
                if(dy < 0){
                    cy = 1;
                }
                if(dx < -0.1){
                    cx = 1;
                }
            }
            var lg = DEFS.append("radialGradient")
                        .attr("id", grad_id)
                        .attr("cx", cx)
                        .attr("cy", cy)
                        .attr("r", 0.9)
                lg.append("stop")
                    .attr("offset", "10%")
                    .attr("stop-color", "rgb(110,110,110)")
                    .attr("stop-opacity", "1")
                lg.append("stop")
                    .attr("offset", "80%")
                    .attr("stop-color", "rgb(110,110,110)")
                    .attr("stop-opacity", "0")

            var el = SVG.append('path')
                        .attr('d', points)
                        .attr('data-tri', this.tri_num)
                        .attr('data-corner', COLORS.length)
                        .attr('stroke', 'transparent')
                        .attr('class', 'corner shape tri' + this.tri_num)
                        .attr('zIndex', 0)
                        .attr('fill', 'url(#' + grad_id + ')')
                        .on("mouseup", function(e) {
                            if(getMode() == "Triangle"){
                                var tri_id = d3.select(this).attr("data-tri");
                                var tri_shapes = d3.selectAll(".tri" + tri_id);
                                var corner_ids = tri_shapes.nodes().map(function(cv){ return +cv.getAttribute("data-corner"); })
                                var cc = get_current_rgb();
                                corner_ids.forEach(function(corner_id){
                                    COLORS[corner_id].selectChild("stop:nth-child(1)").attr("stop-color", cc)
                                    COLORS[corner_id].selectChild("stop:nth-child(2)").attr("stop-color", cc)
                                    d3.select(this).attr('original_color', cc);        
                                });
                                send_colors_to_tris();
                            }
                        })
            var px = this.x - 0.55*this.radius * Math.sin(theta);
            var py = this.y - 0.55*this.radius * Math.cos(theta);
            POINTS.push({"x": px, "y": py})

            var elc = SVG.append('circle')
                    .attr('cx', px)
                    .attr('cy', py)
                    .attr('r', 23)
                    .attr('class', 'corner circle')
                    .attr('zIndex', 1)
                    .attr('data-tri', this.tri_num)
                    .attr('data-corner', COLORS.length)
                    .attr('fill', 'transparent')
                    .on("mouseover", function(e){
                        if(getMode() == "Corner"){
                        var corner_id = d3.select(this).attr("data-corner");
                        d3.select(this).attr('original_color', COLORS[corner_id].selectChild("stop:nth-child(1)").attr("stop-color"));
                        var cc = get_current_rgb();
                        COLORS[corner_id].selectChild("stop:nth-child(1)").attr("stop-color", cc)
                        COLORS[corner_id].selectChild("stop:nth-child(2)").attr("stop-color", cc)
                        }
                    })
                    .on("mouseout", function(e){
                        if(getMode() == "Corner"){
                            var corner_id = d3.select(this).attr("data-corner");
                            var original_color = d3.select(this).attr('original_color')
                            COLORS[corner_id].selectChild("stop:nth-child(1)").attr("stop-color", original_color)
                            COLORS[corner_id].selectChild("stop:nth-child(2)").attr("stop-color", original_color)
                        }
                    })
                    .on("click", function(e){
                        if(getMode() == "Corner"){
                            var corner_id = d3.select(this).attr("data-corner");
                            var cc = get_current_rgb();
                            COLORS[corner_id].selectChild("stop:nth-child(1)").attr("stop-color", cc)
                            COLORS[corner_id].selectChild("stop:nth-child(2)").attr("stop-color", cc)
                            d3.select(this).attr('original_color', cc);
                            send_colors_to_tris();
                        }
                    })


            CORNERS.push(el);
            COLORS.push(lg);
            this.colors.push(lg);

            corner_num += 1;
            if(corner_num > 2){
                break;
            }
        }

    }
}

const POINTS = [];
const TRIS = [];
const CORNERS = [];
const COLORS = [];
let TRI_NUM = 0;


function triangle_row(x, y, start, end){
    for(let i=start; i<end; i++){
        let y_offset = ((i % 2) == 0) ? 0 : SIDE_LEN*Math.tan(PI6);
        let tri = new Triangle(x + i * SIDE_LEN, y - y_offset, SIDE_LEN, (i%2==0)?(1.9999999*PI3):PI3, TRI_NUM);
        tri.setPoints();
        tri.showPoly();
        TRIS.push(tri);
        TRI_NUM += 1
    }
    return;
}

let SVG = null;
let DEFS = null;
let SIDE_LEN = 64;
let PALETTE = null;
let PALETTE_COLORS = [];
let SELECTED_COLOR = null;

function show_data(){
    SVG = d3.select("#triangles");
    DEFS = d3.select("#triangles>defs");
    let x = SIDE_LEN * 2;
    let y = SIDE_LEN*1.25;
    triangle_row(x, y, 0, 3);
    y += SIDE_LEN * Math.cos(PI6) * 2;
    x -= SIDE_LEN;
    triangle_row(x, y, 0, 5);
    x -= SIDE_LEN;
    y += SIDE_LEN * Math.cos(PI6) * 2;
    triangle_row(x, y, 1, 6);

    var tri_shapes = d3.selectAll('.corner');
    var vals = tri_shapes.nodes().map(function(cv){ return +cv.getAttribute("zIndex"); })
    tri_shapes.data(vals)
    tri_shapes.sort();

    var ls = [0.4];
    
    var h = 20;
    for(var i=0; i < 8; i++){
        var l = ls[Math.floor(Math.random()*ls.length)];
        PALETTE_COLORS.push(new Color(h, 1, l));
        h += (24*1.8);
        h = h % 360;
    }
    
    PALETTE = d3.select("#palette")
                .selectAll("li")
                .data(PALETTE_COLORS)
                    .enter().append("li").append("a")
                    .style("background-color", function(d) { return d.getRgbStr(); })
                    .on("click", function(e, d){
                        d3.selectAll("#palette li").attr("class", "");
                        SELECTED_COLOR = d;
                        d3.select(this.parentNode).attr("class", "selected");
                    })
    SELECTED_COLOR = PALETTE_COLORS[0];
    d3.select("#palette li:first-child").attr("class", "selected");

    document.querySelector('.mode').addEventListener("change", changed_mode);
    // changed_color();

}

var div = document.getElementById('div'), x1 = 0, y1 = 0, x2 = 0, y2 = 0;

function reCalc() { //This will restyle the div
    var x3 = Math.min(x1,x2)-6; //Smaller X
    var x4 = Math.max(x1,x2)-6; //Larger X
    var y3 = Math.min(y1,y2)-6; //Smaller Y
    var y4 = Math.max(y1,y2)-6; //Larger Y
    div.style.left = x3 + 'px';
    div.style.top = y3 + 'px';
    div.style.width = x4 - x3 + 'px';
    div.style.height = y4 - y3 + 'px';
}

function rect_mousedown(e){
    div.hidden = 0; //Unhide the div
    x1 = e.clientX; //Set the initial X
    y1 = e.clientY; //Set the initial Y
    reCalc();
}

function rect_mouseup(e) {
    POINTS.forEach(function(p, i){        
        if(p.x+10 > d3.least([x1, x2]) && p.x < d3.greatest([x1, x2])+10 &&
        p.y+10 > d3.least([y1, y2]) && p.y < d3.greatest([y1, y2])+10 ){
            var cc = get_current_rgb();
            COLORS[i].selectChild("stop:nth-child(1)").attr("stop-color", cc)
            COLORS[i].selectChild("stop:nth-child(2)").attr("stop-color", cc)
            d3.select(this).attr('original_color', cc);
        }
    })
    send_colors_to_tris();
    div.hidden = 1; //Hide the div
}

function rectModeStart(){
    window.addEventListener("mousedown", rect_mousedown, false);
    onmousemove = function(e) {
        x2 = e.clientX;
        y2 = e.clientY;
        reCalc();
    };
    rect_mouseup = window.addEventListener("mouseup", rect_mouseup, true);
}

function rectModeStop(){
    window.removeEventListener("mousedown", rect_mousedown);
    window.removeEventListener("mouseup", rect_mouseup);
    onmousemove = null;
}

function changed_color(e){
    var h = +d3.select('#hue_value').text();
    var s = +d3.select('#sat_value').text();
    var l = +d3.select('#light_value').text();
    var c = new Color(h, s, l);
    d3.select("#palette .selected a").style("background-color", c.getRgbStr());
    d3.select("#palette .selected a").datum(c);
    SELECTED_COLOR = c;
}

function getMode(){
    return document.querySelector('.mode:checked').value;
}

function changed_mode(e){
    if(getMode() == "Rectangle"){
        rectModeStart();
    }else{
        rectModeStop();
    }
}

d3.select(window).on("load", show_data);


var hue_slider = d3
    .sliderHorizontal()
    .min(0)
    .max(360)
    .step(6)
    .width(300)
    .displayValue(false)
    .on('onchange', (val) => {
    d3.select('#hue_value').text(val);
    changed_color();
    });

d3.select('#hue_slider')
    .append('svg')
    .attr('width', 400)
    .attr('height', 67)
    .append('g')
    .attr('transform', 'translate(30,30)')
    .call(hue_slider);

d3.select("#hue_slider .slider")
    .insert("rect", ".parameter-value")
    .attr("width", 300)
    .attr("height", 40)
    .attr("y", -20)
    .attr("fill", "url(#rainbow)");

var sat_slider = d3
    .sliderHorizontal()
    .min(0)
    .max(1)
    .step(0.05)
    .width(300)
    .default(0.9)
    .displayValue(false)
    .on('onchange', (val) => {
    d3.select('#sat_value').text(val);
        changed_color();
    });

d3.select('#sat_slider')
    .append('svg')
    .attr('width', 400)
    .attr('height', 67)
    .append('g')
    .attr('transform', 'translate(30,30)')
    .call(sat_slider);

var light_slider = d3
    .sliderHorizontal()
    .min(0)
    .max(1)
    .step(0.05)
    .width(300)
    .default(0.5)
    .displayValue(false)
    .on('onchange', (val) => {
    d3.select('#light_value').text(val);
        changed_color();
    });

d3.select('#light_slider')
    .append('svg')
    .attr('width', 400)
    .attr('height', 67)
    .append('g')
    .attr('transform', 'translate(30,30)')
    .call(light_slider);

)=====";
#endif
