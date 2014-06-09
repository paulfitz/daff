var fs = require('fs');
var coopy = require('daff');
var tester = require('tester');
var assert = require('assert');

var t1 = new coopy.TableView([["Name","Number","Color","Mood","Food"],
				   ["John",14,"Blue","Sad","Sandwich"],
				   ["Jane",99,"Green","Happy","Apple"]]);

var t2 = new coopy.TableView([["Name","Number","Color","Mood","Food"],
				   ["John",14,"Blue","Sad","Sandwich"],
				   ["Jane",99,"Green","Happy-ish","Apple"]]);

var ct = coopy.Coopy.compareTables(t1,t2);
var align = ct.align();
var options = new coopy.CompareFlags();
// this may end up being the default, once these tests are passing
options.show_unchanged_columns = false;
options.unchanged_column_context = 0;
var td = new coopy.TableDiff(align,options);
var output = new coopy.TableView([]);
td.hilite(output);
assert(output.getCell(0,0) == "@@");
assert(output.getCell(1,0) == "Name");
assert(output.getCell(2,0) == "...");
assert(output.getCell(3,0) == "Mood");
assert(output.getCell(4,0) == "...");
tester.round_trip_with_flags(t1,t2,"MoodSandwich",options);

var lots_of_cols_example = {
    "key": "one_small_change",
    "parent": [[]],
    "local": [["Col1","Col2","Col3","Col4","Col5","Col6","Col7","Col8","Col9","Col10"],
	      [1,2,3,4,5,6,7,8,9,10],
	      [11,12,13,14,15,16,17,18,19,20],
	      [21,22,23,24,23,26,27,28,29,30]],
    "remote": [["Col1","Col2","Col3","Col4","Col5","Col6","Col7","Col8","Col9","Col10"],
	      [1,2,3,4,5,6,7,8,9,10],
	      [11,12,13,14,15,16,17,18,19,20],
	      [21,22,23,24,25,26,27,28,29,30]]
};

{
    var eg = lots_of_cols_example;
    var t1 = new coopy.TableView(eg["local"]);
    var t2 = new coopy.TableView(eg["remote"]);
    var ct = coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    var options = new coopy.CompareFlags();
    var td = new coopy.TableDiff(align,options);
    var output = new coopy.TableView([]);
    td.hilite(output);
    tester.round_trip_with_flags(t1,t2,"lots_of_cols",options);
}