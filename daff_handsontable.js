(function() {

var coopy = null;
if (typeof exports != "undefined") {
    if (typeof exports.Coopy != "undefined") {
	coopy = exports;
    }
}
if (coopy == null) {
    coopy = window.coopy;
}

var diffRenderer = function (instance, td, row, col, prop, value, cellProperties) {
    var tt = {};
    tt.getCellText = function(x,y) {
	var v = instance.getDataAtCell(y,x);
	if (v==null) return v;
	return "" + v;
    }

    var cell = coopy.DiffRender.renderCell(tt,col,row);
    var className = cell.category;
    var value2 = cell.pretty_value;

    if (typeof Handsontable != "undefined") {
	Handsontable.TextCell.renderer.apply(this, [instance,
						    td, row, col, prop,
						    value2,
						    cellProperties]);
    }
    if (className!="") {
	td.className = className;
    }    
    return value2;
}

coopy.diffRenderer = diffRenderer;

})();
