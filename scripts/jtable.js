var coopy = (typeof require != "undefined") ? require('coopy_node') : coopy;

var JTable = function(w,h) {
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

JTable.prototype.isResizable = function() {
    return true;
}

JTable.prototype.resize = function(w,h) {
    this.width = w;
    this.height = h;
    return true;
}

JTable.prototype.clear = function() {
    this.data = new Array(w*h);
}



var JTable2 = function(data) {
    this.data = data;
    this.height = data.length;
    this.width = 0;
    if (this.height>0) {
	this.width = data[0].length;
    }
}

JTable2.prototype.get_width = function() {
    return this.width;
}

JTable2.prototype.get_height = function() {
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

JTable2.prototype.isResizable = function() {
    return true;
}

JTable2.prototype.resize = function(w,h) {
    this.width = w;
    this.height = h;
    for (var i=0; i<this.data.length; i++) {
	var row = this.data[i];
	while (row.length<this.width) {
	    row.push(null);
	}
    }
    if (this.data.length<this.height) {
	while (this.data.length<this.height) {
	    var row = [];
	    for (var i=0; i<this.width; i++) {
		row.push(null);
	    }
	    this.data.push(row);
	}
    }
    return true;
}

JTable2.prototype.clear = function() {
    for (var i=0; i<this.data.length; i++) {
	var row = this.data[i];
	for (var j=0; j<row.length; j++) {
	    row[j] = null;
	}
    }
}

JTable2.prototype.trim = function() {
    var changed = this.trimRows();
    changed = changed || this.trimColumns();
    return changed;
}

JTable2.prototype.trimRows = function() {
    var changed = false;
    while (true) {
	if (this.height==0) return changed;
	var row = this.data[this.height-1];
	for (var i=0; i<this.width; i++) {
	    var c = row[i];
	    if (c!=null && c!="") return changed;
	}
	this.height--;
    }
}

JTable2.prototype.trimColumns = function() {
    var top_content = 0;
    for (var i=0; i<this.height; i++) {
	if (top_content>=this.width) break;
	var row = this.data[i];
	for (var j=0; j<this.width; j++) {
	    var c = row[j];
	    if (c!=null && c!="") {
		if (j>top_content) {
		    top_content = j;
		}
	    }
	}
    }
    if (this.height==0 || top_content+1==this.width) return false;
    this.width = top_content+1;
    return true;
}

JTable2.prototype.getData = function() {
    return data;
}

if (typeof exports != "undefined") {
    exports.JTable = JTable;
    exports.JTable2 = JTable2;
}

