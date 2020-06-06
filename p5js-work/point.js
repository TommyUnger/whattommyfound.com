class Point{
    constructor(x, y){
        this.x = x;
        this.y = y;
    }

    render(){
        fill(40);
        ellipse(this.x, this.y, 7, 4);
    }

    toString(){
        return Math.floor(this.x) + ", " + Math.floor(this.y);
    }
}
