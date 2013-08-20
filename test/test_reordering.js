var fs = require('fs');
var coopy = require('coopyhx');
var tester = require('tester');

var planets = [ ["Mercury"], ["Venus"], ["Mars"], ["Earth"], ["Jupiter"], ["Saturn"], ["Uranus"], ["Neptune"] ];

function factorial(n) {
    if (n<=1) return 1;
    return n*factorial(n-1);
}

function pick_planets(remaining,picked,k) {
    if (remaining.length==0) return;
    var idx = k % remaining.length;
    //console.log(idx + " " + remaining + " // " + picked);
    picked.push(remaining.splice(idx,1)[0]);
    k = Math.floor(k/remaining.length);
    pick_planets(remaining,picked,k);
}

function get_table(n,len) {
    var lst = [];
    pick_planets(planets.slice(0,len-1),lst,n);
    return new coopy.CoopyTableView([["Planets"]].concat(lst));
}


var N = 4; // should occasionally test with a higher number

for (var k1=1; k1<=N; k1++) {
    var top1 = factorial(k1);
    for (var k2=1; k2<=N; k2++) {
	var top2 = factorial(k2);
	for (var i=0; i<top1; i++) {
	    var t1 = get_table(i,k1);
	    for (var j=0; j<top2; j++) {
		var t2 = get_table(j,k2);
		tester.round_trip(t1, t2, k1 + " " + k2 + " : " + i + " -> " + j);
	    }
	}
    }
}
