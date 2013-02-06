var coopy = require('coopy');
var assert = require('assert');
var jtable = require('jtable');

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

// 100 should soon be several orders of magnitude greater
for (var i=0; i<100; i++) {
    var row = [];
    for (var j=0; j<5; j++) {
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

var t1 = new jtable.JTable2(data1);
var t2 = new jtable.JTable2(data2);
var ct = new coopy.CompareTable();
console.log("starting...");
var comp = coopy.Comparison.compareTables(ct,t1,t2);
var align = ct.align();
console.log("done...");
console.log(align.toOrder().getList().length);
