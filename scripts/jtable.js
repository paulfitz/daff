var coopy = require('coopy');

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

exports.JTable = JTable;



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

exports.JTable = JTable;
exports.JTable2 = JTable2;

