var coopy = require('daff');
var assert = require('assert');

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

var t1 = new coopy.TableView(data1);
var t2 = new coopy.TableView(data2);
console.log("starting many rows...");
var ct = new coopy.compareTables(t1,t2);
var align = ct.align();
console.log("done alignment...");
console.log(align.toOrder().getList().length);
console.log("done ordering...");

data = [];
for (var i=0; i<100; i++) {
    var row = [];
    for (var j=0; j<1000; j++) {
	row.push(at);
	at++;
    }
    data.push(row);
}

data1 = data;
data2 = clone2(data1);
data2[0][0] = 2;
data2.length = data2.length - 1;
data1 = enheader(data1);
data2 = enheader(data2);

var t1 = new coopy.TableView(data1);
var t2 = new coopy.TableView(data2);
console.log("starting many columns...");
var ct = new coopy.compareTables(t1,t2);
var align = ct.align();
console.log("done alignment...");
console.log(align.toOrder().getList().length);
console.log("done ordering...");

var options = new coopy.CompareFlags();
options.unchanged_column_context = 3;
var td = new coopy.TableDiff(align,options);
var output = new coopy.TableView([]);
td.hilite(output);
console.log("done hiliting...");
