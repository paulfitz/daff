// try using coopy classes from "outside"

function printf(msg) {
    js.Boot.__trace(msg,null);
}

st = new SimpleTable(5,5);
st.set_cell(2,3,"ok");
printf("cell is " + st.get_cell(2,3));
Coopy.show(st);

JTable = function(w,h) {
    this.width = w;
    this.height = h;
    this.data = new Array(w*h);
}

JTable.prototype.get_width = function() {
    return this.width;
}

JTable.prototype.get_height = function() {
    return this.height;
}

JTable.prototype.get_cell = function(x,y) {
    return this.data[x+y*this.height];
}

JTable.prototype.set_cell = function(x,y,c) {
    this.data[x+y*this.height] = c;
}


jt = new JTable(5,5);
jt.set_cell(2,3,"ok");
printf("cell is " + jt.get_cell(2,3));
Coopy.show(jt);

var compare = new Compare();
var d1 = 5;
var d2 = 5;
var d3 = 15;
var report = new Report();
compare.compare(d1,d2,d3,report);
printf("report is " + report);
