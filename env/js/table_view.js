(function() {

var CellView = function() {
}

CellView.prototype.toString = function(d) {
    return ""+d;
}

CellView.prototype.equals = function(d1,d2) {
    return d1==d2;
}

CellView.prototype.toDatum = function(d) {
    return d;
}

CellView.prototype.makeHash = function() {
    return {};
}

CellView.prototype.hashSet = function(d,k,v) {
    d[k] = v;
}

CellView.prototype.hashGet = function(d,k) {
    return d[k];
}

CellView.prototype.hashExists = function(d,k) {
    return k in d;
}

CellView.prototype.isHash = function(d) {
    return d && (typeof d  === "object");
}

var TableView = function(data) {
    // variant constructor (cols, rows)
    if (arguments.length==2) {
	var lst = [];
	for (var i=0; i<arguments[1]; i++) {
	    var row = [];
	    for (var j=0; j<arguments[0]; j++) {
		row.push(null);
	    }
	    lst.push(row);
	}
	data = lst;
    }
    this.data = data;
    this.height = data.length;
    this.width = 0;
    if (this.height>0) {
	this.width = data[0].length;
    }
}

TableView.prototype.get_width = function() {
    return this.width;
}

TableView.prototype.get_height = function() {
    return this.height;
}

TableView.prototype.getCell = function(x,y) {
    return this.data[y][x];
}

TableView.prototype.setCell = function(x,y,c) {
    this.data[y][x] = c;
}

TableView.prototype.toString = function() {
    return daff.SimpleTable.tableToString(this);
}

TableView.prototype.getCellView = function() {
    return new CellView();
}

TableView.prototype.isResizable = function() {
    return true;
}

TableView.prototype.resize = function(w,h) {
    this.width = w;
    this.height = h;
    for (var i=0; i<this.data.length; i++) {
	var row = this.data[i];
	if (row==null) {
	    row = this.data[i] = [];
	}
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

TableView.prototype.clear = function() {
    for (var i=0; i<this.data.length; i++) {
	var row = this.data[i];
	for (var j=0; j<row.length; j++) {
	    row[j] = null;
	}
    }
}

TableView.prototype.trim = function() {
    var changed = this.trimRows();
    changed = changed || this.trimColumns();
    return changed;
}

TableView.prototype.trimRows = function() {
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

TableView.prototype.trimColumns = function() {
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

TableView.prototype.getData = function() {
    return this.data;
}

TableView.prototype.clone = function() {
    var ndata = [];
    for (var i=0; i<this.get_height(); i++) {
	ndata[i] = this.data[i].slice();
    }
    return new TableView(ndata);
}

TableView.prototype.create = function() {
    return new TableView([]);
}

TableView.prototype.insertOrDeleteRows = function(fate, hfate) {
    var ndata = [];
    for (var i=0; i<fate.length; i++) {
        var j = fate[i];
        if (j!=-1) {
	    ndata[j] = this.data[i];
        }
    }
    // let's preserve data
    //this.data = ndata;
    this.data.length = 0;
    for (var i=0; i<ndata.length; i++) {
	this.data[i] = ndata[i];
    }
    this.resize(this.width,hfate);
    return true;
}

TableView.prototype.insertOrDeleteColumns = function(fate, wfate) {
    if (wfate==this.width && wfate==fate.length) {
	var eq = true;
	for (var i=0; i<wfate; i++) {
	    if (fate[i]!=i) {
		eq = false;
		break;
	    }
	}
	if (eq) return true;
    }
    for (var i=0; i<this.height; i++) {
	var row = this.data[i];
	var nrow = [];
	for (var j=0; j<this.width; j++) {
	    if (fate[j]==-1) continue;
	    nrow[fate[j]] = row[j];
	}
	while (nrow.length<wfate) {
	    nrow.push(null);
	}
	this.data[i] = nrow;
    }
    this.width = wfate;
    return true;
}

TableView.prototype.isSimilar = function(alt) {
    if (alt.get_width()!=this.get_width()) return false;
    if (alt.get_height()!=this.get_height()) return false;
    for (var c=0; c<this.width; c++) {
	for (var r=0; r<this.height; r++) {
	    var v1 = "" + this.getCell(c,r);
	    var v2 = "" + alt.getCell(c,r); 
	    if (v1!=v2) {
		console.log("MISMATCH "+ v1 + " " + v2);
		return false;
	    }
	}
    }
    return true;
}

TableView.prototype.getMeta = function() {
    return null;
}

daff.TableView = TableView;

daff.CellView = CellView;
daff.TableView = TableView;

})();
