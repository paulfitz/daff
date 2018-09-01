(function() {

/**
 *
 * Wrapper around a table expressed as rows of hashes.  A mapping function can be passed if the
 * representation needs to be adapted a little.  The function will be passed data[i] and should
 * return a simple hash of { "col1": "val1", "col2": "val2", ... }
 *
 */
var NdjsonTable = function(data,mapping) {
    this.data = data;
    this.height = data.length;
    this.width = 0;
    this.columns = [];
    this.hasMapping = (mapping!=null);
    if (mapping==null) {
        mapping = function(x) { return x };
    }
    this.mapping = mapping;
    var column_name_to_number = {};
    if (this.height>0) {
        // We scan all rows to find all fields in use.
        for (var i=0; i<this.height; i++) {
            var row = mapping(data[i]);
            for (var key in row) {
                if (key in column_name_to_number) continue;
                if (!row.hasOwnProperty(key)) continue;
                this.width++;
                column_name_to_number[key] = this.columns.length;
                this.columns.push(key);
            }
        }
    }
    this.columns.sort(); // make order deterministic
    if (this.height>0) this.height++;
}

NdjsonTable.prototype.get_width = function() {
    return this.width;
}

NdjsonTable.prototype.get_height = function() {
    return this.height;
}

NdjsonTable.prototype.getCell = function(x,y) {
    var key = this.columns[x];
    if (key == null) throw Error("bad key");
    if (y==0) return key;
    return this.mapping(this.data[y-1])[key];
}

NdjsonTable.prototype.setCell = function(x,y,c) {
    var key = this.columns[x];
    if (key == null && y!=0) throw Error("bad key");
    if (y==0) {
        if (key!=null) throw Error("cannot yet change column set in this type of table");
        this.columns[x] = c;
    } else {
        this.mapping(this.data[y-1])[key] = c;
    }
}

NdjsonTable.prototype.toString = function() {
    return daff.SimpleTable.tableToString(this);
}

NdjsonTable.prototype.getCellView = function() {
    return new daff.CellView();
}

NdjsonTable.prototype.isResizable = function() {
    // Ndjson wrapper can't usefully cope with schema changes.
    return false;
}

NdjsonTable.prototype.resize = function(w,h) {
    return false;
}

NdjsonTable.prototype.clear = function() {
    return false;
}

NdjsonTable.prototype.getData = function() {
    return this.data;
}

NdjsonTable.prototype.clone = function() {
    var ndata = [];
    for (var i=0; i<this.data.length; i++) {
        var row = ndata[i] = {};
        for (var c=0; c<this.columns; c++) {
            var key = this.columns[c];
	    row[key] = this.data[i][key];
        }
    }
    return new NdjsonTable(ndata,this.hasMapping?this.mapping:null);
}

NdjsonTable.prototype.insertOrDeleteRows = function(fate, hfate) {
    return false;
}

NdjsonTable.prototype.insertOrDeleteColumns = function(fate, wfate) {
    return false;
}

NdjsonTable.prototype.getMeta = function() {
    return null;
}


daff.NdjsonTable = NdjsonTable;

})();
