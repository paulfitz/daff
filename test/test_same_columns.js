var coopy = require('coopy');
var assert = require('assert');
var jtable = require('jtable');

var t1 = new jtable.JTable2([["Name","Number"],["John",14]]);
var t2 = new jtable.JTable2([["Name","Number"],["Mary",17],["John",15]]);
var d1 = new coopy.ViewedDatum(t1,new coopy.TableView());
var d1 = new coopy.ViewedDatum(t2,new coopy.TableView());

var ct = new coopy.CompareTable();
var comp = new coopy.Comparison();
comp.a = t1;
comp.b = t2;
ct.compare(comp);
assert(comp.has_same_columns);

t2.setCell(0,0,"Number");
comp.reset();
ct.compare(comp);
assert(!comp.has_same_columns);
