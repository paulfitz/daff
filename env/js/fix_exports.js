
var daff = null;
if (typeof exports !== 'undefined' && exports.coopy) {
    // avoid having excess nesting (coopy.coopy) when using node
    for (f in exports.coopy) { 
	if (exports.coopy.hasOwnProperty(f)) {
	    exports[f] = exports.coopy[f]; 
	}
    } 
    // promote methods of coopy.Coopy
    for (f in exports.Coopy) { 
	if (exports.Coopy.hasOwnProperty(f)) {
	    exports[f] = exports.Coopy[f]; 
	}
    } 
    daff = exports;
} else {
    // promote methods of coopy.Coopy
    for (f in coopy.Coopy) { 
	if (coopy.Coopy.hasOwnProperty(f)) {
	    coopy[f] = coopy.Coopy[f]; 
	}
    } 
    window.daff = daff = coopy;
}
