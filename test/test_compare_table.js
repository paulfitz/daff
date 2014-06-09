var coopy = require('daff');
var assert = require('assert');

var t1 = new coopy.TableView([[1,2,3],[4,5,6]]);
var t2 = new coopy.TableView([[1,2,3],[4,5,6]]);
var t3 = new coopy.TableView([[1,2,3],[4,5,6]]);
var d1 = new coopy.ViewedDatum(t1,new coopy.SimpleView());
var d2 = new coopy.ViewedDatum(t2,new coopy.SimpleView());
var d3 = new coopy.ViewedDatum(t3,new coopy.SimpleView());

t2.setCell(2,1,"hello");
t3.setCell(2,1,"goodbye");

var cmp = new coopy.Compare();
var report = new coopy.Report();

cmp.compare(d1,d1,d2,report);
assert.equal(report.changes.length,1);
assert.equal(report.changes[0].mode,"REMOTE_CHANGE");

cmp.compare(d1,d2,d1,report);
assert.equal(report.changes.length,1);
assert.equal(report.changes[0].mode,"LOCAL_CHANGE");

cmp.compare(d1,d2,d2,report);
assert.equal(report.changes.length,1);
assert.equal(report.changes[0].mode,"SAME_CHANGE");

cmp.compare(d1,d1,d1,report);
assert.equal(report.changes.length,0);

cmp.compare(d1,d2,d3,report);
assert.equal(report.changes.length,1);
assert.equal(report.changes[0].mode,"BOTH_CHANGE");

cmp.compare(d1,d1,d1,report);
assert.equal(report.changes.length,0);

cmp.compare(d1,d1,d2,report);
assert.equal(report.changes.length,1);


var t4 = new coopy.TableView([[1,2,3],[4,5,6]]);
var t5 = new coopy.TableView([[1,2,3],[4,5,6],[7,8,9]]);
var d4 = new coopy.ViewedDatum(t4,new coopy.SimpleView());
var d5 = new coopy.ViewedDatum(t5,new coopy.SimpleView());
cmp.compare(d4,d4,d5,report);
assert.equal(report.changes.length,1);
assert.equal(report.changes[0].mode,"REMOTE_CHANGE");

