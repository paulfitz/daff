

if (typeof exports != "undefined") {
    // avoid having excess nesting (coopy.coopy) when using node
    for (f in exports.coopy) { 
	if (exports.coopy.hasOwnProperty(f)) {
	    exports[f] = exports.coopy[f]; 
	}
    } 
}
