if(typeof window["coopy"] == "undefined") window["coopy"] = {};
window["coopy"]["diffRenderer"] = function (instance, td, row, col, prop, value, cellProperties) {
    Handsontable.TextCell.renderer.apply(this, arguments);
    var v0 = instance.getDataAtCell(row, 0);
    var v1 = instance.getDataAtCell(0, col);
    var removed_column = false;
    if (v1!=null) {
	if (v1.indexOf("+++")>=0) {
 	    td.className = 'add';
	} else if (v1.indexOf("---")>=0) {
 	    td.className = 'remove';
	    removed_column = true;
	} 
    }
    if (v0!=null) {
	if (v0 == "!") {
 	    td.className = 'spec';
	} else if (v0 == "@@") {
 	    td.className = 'header';
	} else if (v0 == "+++") {
 	    if (!removed_column) td.className = 'add';
	} else if (v0 == "---") {
 	    td.className = 'remove';
	} else if (v0.indexOf("->")>=0) {
	    if (value!=null) {
 		if (!removed_column) {
		    var tokens = v0.split("!");
		    var full = v0;
		    var part = tokens[1];
		    if (part==null) part = full;
		    if (value.indexOf(part)>=0) {
			var name = "modify";
			if (part!=full) {
			    if (value.indexOf(full)>=0) {
				name = 'conflict';
			    }
			}
			td.className = name;
		    }
		}
	    }
	}
    }
    if (value==null || value=="null") {
	td.className = td.className + " null";
	$(td).text("");
    }
}

