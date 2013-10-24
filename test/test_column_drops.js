var fs = require('fs');
var coopy = require('coopyhx');
var tester = require('tester');
var assert = require('assert');

var t1 = new coopy.CoopyTableView([["Name","Number","Color","Mood","Food"],
				   ["John",14,"Blue","Sad","Sandwich"],
				   ["Jane",99,"Green","Happy","Apple"]]);

var t2 = new coopy.CoopyTableView([["Name","Number","Color","Mood","Food"],
				   ["John",14,"Blue","Sad","Sandwich"],
				   ["Jane",99,"Green","Happy-ish","Apple"]]);

var ct = coopy.Coopy.compareTables(t1,t2);
var align = ct.align();
var options = new coopy.CompareFlags();
// this may end up being the default, once these tests are passing
options.show_unchanged_columns = false;
options.unchanged_column_context = 0;
var td = new coopy.TableDiff(align,options);
var output = new coopy.CoopyTableView([]);
td.hilite(output);
assert(output.getCell(0,0) == "@@");
assert(output.getCell(1,0) == "Name");
assert(output.getCell(2,0) == "...");
assert(output.getCell(3,0) == "Mood");
assert(output.getCell(4,0) == "...");
tester.round_trip_with_flags(t1,t2,"MoodSandwich",options);
