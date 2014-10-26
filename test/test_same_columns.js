var coopy = require('daff');
var assert = require('assert');

var t1 = new coopy.TableView([["Name","Number"],["John",14]]);
var t2 = new coopy.TableView([["Name","Number"],["Mary",17],["John",15]]);

var ct = new coopy.Coopy.compareTables(t1,t2);
ct.run();
var comp = ct.getComparisonState();
assert(comp.has_same_columns);

t2.setCell(0,0,"Number");
comp.reset();
ct.run();
assert(!comp.has_same_columns);
