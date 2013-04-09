var coopy = require('coopy');
var assert = require('assert');
var coopy_view = require('coopy_view');

function clone2(x) {
    var result = [];
    for (var i=0; i<x.length; i++) {
	result.push(x[i].slice(0));
    }
    return result;
}

function enheader(x) {
    var result = [];
    for (var i=0; i<x[0].length; i++) {
	result.push("col"+i);
    }
    return ([result]).concat(x);
}

var at = 0;
var data = [];

for (var i=0; i<10000; i++) {
    var row = [];
    for (var j=0; j<10; j++) {
	row.push(at);
	at++;
    }
    data.push(row);
}

data1 = data;
data2 = clone2(data1);
data2[0][0] = 2;
data1 = enheader(data1);
data2 = enheader(data2);

var t1 = new coopy_view.CoopyTableView(data1);
var t2 = new coopy_view.CoopyTableView(data2);
console.log("starting...");
var ct = new coopy.Coopy.compareTables(t1,t2);
var align = ct.align();
console.log("done alignment...");
console.log(align.toOrder().getList().length);
console.log("done ordering...");
