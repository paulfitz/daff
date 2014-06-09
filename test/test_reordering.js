var fs = require('fs');
var coopy = require('daff');
var tester = require('tester');

var planets = [ ["Mercury"], ["Venus"], ["Mars"], ["Earth"], ["Jupiter"], ["Saturn"], ["Uranus"], ["Neptune"] ];

function factorial(n) {
    if (n<=1) return 1;
    return n*factorial(n-1);
}

function nchoosek(n,k) {
    if (n<=1) return 1;
    if (k<=0) return 1;
    return n*nchoosek(n-1,k-1);
}

function pick_planets(remaining,picked,k,target) {
    if (picked.length==target) return;
    var idx = k % remaining.length;
    //console.log(idx + " " + remaining + " // " + picked + " T " + target);
    picked.push(remaining.splice(idx,1)[0]);
    k = Math.floor(k/remaining.length);
    pick_planets(remaining,picked,k,target);
}

function get_table(n,len_all,len_sel) {
    var lst = [];
    pick_planets(planets.slice(0,len_all),lst,n,len_sel);
    return new coopy.TableView([["Planets"]].concat(lst));
}

function get_flipped_table(n,len_all,len_sel) {
    var lst = [];
    pick_planets(planets.slice(0,len_all),lst,n,len_sel);
    for (var i=0; i<lst.length; i++) {
	lst[i] = lst[i][0];
    }
    return new coopy.TableView([lst]);
}


var test_cases = [
    { "k1": 5, "k2": 3, "i": 0, "j": 4, "mode": "flipped", "N": 5 },
    { "k1": 4, "k2": 4, "i": 0, "j": 32, "mode": "flipped", "N": 5 }
];

for (var k=0; k<test_cases.length; k++) {
    var c = test_cases[k];
    var N = c["N"];
    var k1 = c["k1"];
    var k2 = c["k2"];
    var i = c["i"];
    var j = c["j"];
    var mode = c["mode"];
    var fn = (mode=="flipped")?get_flipped_table:get_table;
    var t1 = fn(i,N,k1);
    var t2 = fn(j,N,k2);
    tester.round_trip(t1, t2, "Case " + mode + " " + k1 + " " + k2 + " : " + i + " -> " + j);
}

var N = 4; // should occasionally test with a higher number

for (var k1=1; k1<=N; k1++) {
    var top1 = nchoosek(N,k1);
    for (var k2=1; k2<=N; k2++) {
	var top2 = nchoosek(N,k2);
	for (var i=0; i<top1; i++) {
	    var t1 = get_table(i,N,k1);
	    for (var j=0; j<top2; j++) {
		var t2 = get_table(j,N,k2);
		tester.round_trip(t1, t2, k1 + " " + k2 + " : " + i + " -> " + j);
	    }
	}
    }
}

for (var k1=1; k1<=N; k1++) {
    var top1 = nchoosek(N,k1);
    for (var k2=1; k2<=N; k2++) {
	var top2 = nchoosek(N,k2);
	for (var i=0; i<top1; i++) {
	    var t1 = get_flipped_table(i,N,k1);
	    for (var j=0; j<top2; j++) {
		var t2 = get_flipped_table(j,N,k2);
		tester.round_trip(t1, t2, "flipped " + k1 + " " + k2 + " : " + i + " -> " + j);
	    }
	}
    }
}

