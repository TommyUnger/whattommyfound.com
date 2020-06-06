class Shape{
    constructor(p, side_num, angle, len, c, depth){
      this.p = p;
      this.c = c;
      this.depth = depth;
      this.angle = angle;
      this.len = len;
      this.renderNum = 0;
      this.side_num = side_num;
      this.sides = Array(side_num);
      this.sections = Array(side_num, 3);
      let cur_angle = angle;
      this.sides[0] = new Line(this.p, cur_angle, this.len);
      this.sections[0] = this.sides[0].getSections(); 
      for(let i=1; i<this.side_num; i++){
        cur_angle += 2 * PI / this.side_num;
        this.sides[i] = new Line(this.sides[i-1].p2, cur_angle, this.len);
        this.sections[i] = this.sides[i].getSections(); 
      }
    }
    
    render(){
      noStroke();
      fill(this.c);
      beginShape();
      this.sides.forEach(function(side){
        vertex(side.p1.x, side.p1.y);
      })
      endShape(CLOSE);
    }

    sketchLines(){
        let main_angle = this.sides[0].angle;
        let line0 = this.sides[0];
        let pp = 1/this.len;
        let szz = 2;
        for(let sl=0; sl<1; sl+=szz*pp){
            // console.log("Loop: " + sl);
            let p0 = line0.getPointOnLine(sl);
            let theta = main_angle+PI/2.33;
            let sketchVec = new Line(p0, theta, 3*line0.len);
            let ip1 = this.sides[1].intersect(sketchVec);
            let ip2 = this.sides[2].intersect(sketchVec);
            let len1 = Line.getLen(p0.x, p0.y, ip1.x, ip1.y);
            let len2 = Line.getLen(p0.x, p0.y, ip2.x, ip2.y);
            let pLast = ip1;
            if(len2 < len1){
                pLast = ip2;
            }
            let sketchLine = (new Line()).fromXY(p0.x, p0.y, pLast.x, pLast.y);
            if(sketchLine.len < 1){
                continue;
            }
            if(Math.random() < 0.2){
                stroke(this.c._getRed(), this.c._getGreen(), this.c._getBlue(), 
                            this.c._getAlpha() + Math.random()*50);
            }else{
                stroke(this.c);
            }
            strokeWeight(1 + Math.random());

            noFill();
            beginShape();
            vertex(p0.x, p0.y);
            let partPerc = (50 / sketchLine.len) * (Math.random()*0.5 + 0.5);
            for(let i=partPerc; i<0.95; i+=partPerc){
                let pNext = sketchLine.getPointOnLine(i);
                let xDiff = 2 - Math.random()*5;
                let yDiff = 2 - Math.random()*5;
                bezierVertex(p0.x + xDiff,
                             p0.y - yDiff,
                             pNext.x - xDiff, 
                             pNext.y + yDiff, 
                             pNext.x, 
                             pNext.y);
                p0 = pNext;
            }
            vertex(pLast.x, pLast.y);
            endShape();
        }
    }
        
}