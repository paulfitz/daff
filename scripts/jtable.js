var coopy = (typeof require != "undefined") ? require('coopy') : window;

var JTable = function(w,h) {
    this.width = w;
    this.height = h;
    this.data = new Array(w*h);
}

JTable.prototype.getWidth = function() {
    return this.width;
}

JTable.prototype.getHeight = function() {
    return this.height;
}

JTable.prototype.getCell = function(x,y) {
    return this.data[x+y*this.width];
}

JTable.prototype.setCell = function(x,y,c) {
    this.data[x+y*this.width] = c;
}

JTable.prototype.toString = function() {
    return coopy.SimpleTable.tableToString(this);
}

JTable.prototype.getCellView = function() {
    return new coopy.SimpleView();
}



var JTable2 = function(data) {
    this.data = data;
    this.height = data.length;
    this.width = data[0].length;
}

JTable2.prototype.getWidth = function() {
    return this.width;
}

JTable2.prototype.getHeight = function() {
    return this.height;
}

JTable2.prototype.getCell = function(x,y) {
    return this.data[y][x];
}

JTable2.prototype.setCell = function(x,y,c) {
    this.data[y][x] = c;
}

JTable2.prototype.toString = function() {
    return coopy.SimpleTable.tableToString(this);
}

JTable2.prototype.getCellView = function() {
    return new coopy.SimpleView();
}

JTable2.prototype.trim = function() {
    var changed = false;
    while (true) {
	if (this.height==0) return changed;
	var row = this.data[this.height-1];
	for (var i=0; i<this.width; i++) {
	    if (row[i]!=null) return changed;
	}
	this.height--;
    }
}

if (typeof exports != "undefined") {
    exports.JTable = JTable;
    exports.JTable2 = JTable2;
}

