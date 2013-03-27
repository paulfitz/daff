
// rename coopy.coopy.* -> coopy.*
for (f in exports.coopy) { 
    if (exports.coopy.hasOwnProperty(f)) {
	exports[f] = exports.coopy[f]; 
     }
} 
