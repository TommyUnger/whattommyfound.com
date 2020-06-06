const LineStatus = {
    NEW: 'NEW',
    INSIDE: 'INSIDE',
    DONE: 'DONE'
}

const LinePos = {
    INSIDE: 'INSIDE',
    OUTSIDE: 'OUTSIDE'
}

class Line{
    constructor(p, angle, len){
      if(p == null){
          return;
      }
      this.m = tan(angle);
      this.b = p.y - this.m*p.x;
      this.status = LineStatus.NEW;
      this.pos = LinePos.OUTSIDE;
      this.depth = 1;
      this.p1 = p;
      this.angle = angle;
      this.len = len;
      this.p2 = new Point(this.p1.x + cos(this.angle)*len, 
                     this.p1.y + sin(this.angle)*this.len); 
    }

    static getLen(x1, y1, x2, y2){
        return sqrt(sq(x1 - x2) + sq(y1 - y2));
    }

    fromXY(x1, y1, x2, y2){
        this.p1 = new Point(x1, y1);
        this.p2 = new Point(x2, y2);
        this.m = (y1 - y2) / (x1 - x2);
        this.len = sqrt(sq(x1 - x2) + sq(y1 - y2));
        this.b = y1 - this.m*x1;
        this.angle = atan(this.m);
        this.status = LineStatus.NEW;
        this.pos = LinePos.OUTSIDE;
        return this;
      }
      
    getSections(){
      this.sections = new Array(3);
      for(let i=0; i<3; i++){
        this.sections[i] = new Line(new Point(this.p1.x + i*cos(this.angle)*this.len/3, 
                                         this.p1.y + i*sin(this.angle)*this.len/3), 
                                         this.angle, this.len / 3);
        this.sections[i].depth = this.depth + 1;
        if(i == 1){
            this.sections[i].pos = LinePos.INSIDE;
        }
      }
      return this.sections;
    }
    
    render(cc){
      stroke(cc);
      strokeWeight(0.5);
      line(this.p1.x, this.p1.y, this.p2.x, this.p2.y);
    }

    getPointOnLine(fract){
        let new_x = (this.p2.x - this.p1.x) * fract + this.p1.x;
        let new_y = (this.p2.y - this.p1.y) * fract + this.p1.y;
        return new Point(new_x, new_y);
    }

    intersect(line1){
        let x = (line1.b - this.b) / (this.m - line1.m);
        let y = this.m * x + this.b;
        if(Math.abs(line1.m) > 10000000000){
            x = line1.p1.x;
        }else if(Math.abs(this.m) > 10000000000){
            x = this.p1.x;
            y = line1.m * x + line1.b;
        }
        return new Point(x, y);
    }

    get toString(){
      return this.p1.x + "," + this.p1.y + " a: " + (this.angle/PI) + " l: " + this.len;
    }
}
