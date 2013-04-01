var coopy = require("coopy");
var assert = require("assert");

var d10 = coopy.ViewedDatum.getSimpleView(10);
var d20 = coopy.ViewedDatum.getSimpleView(20);
var d30 = coopy.ViewedDatum.getSimpleView(30);

var cmp = new coopy.Compare();
var report = new coopy.Report();
cmp.compare(d10,d10,d20,report);
assert.equal(report.changes.length,1);
assert.equal(report.changes[0].mode,"REMOTE_CHANGE");

cmp.compare(d10,d20,d10,report);
assert.equal(report.changes.length,1);
assert.equal(report.changes[0].mode,"LOCAL_CHANGE");

cmp.compare(d10,d20,d20,report);
assert.equal(report.changes.length,1);
assert.equal(report.changes[0].mode,"SAME_CHANGE");

cmp.compare(d10,d10,d10,report);
assert.equal(report.changes.length,0);

cmp.compare(d10,d20,d30,report);
assert.equal(report.changes.length,1);
assert.equal(report.changes[0].mode,"BOTH_CHANGE");

