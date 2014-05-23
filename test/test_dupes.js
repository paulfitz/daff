var fs = require('fs');
var coopy = require('coopyhx');
var assert = require('assert');

var t1 = new coopy.CoopyTableView([["color","sound"],
				   ["red","boink"],
				   ["yellow","whine"],
				   ["yellow","whine"],
				   ["gold","jingle"]]);


var t2 = new coopy.CoopyTableView([["color","sound"],
				   ["red","boink"],
				   ["yellow","whine"],
				   ["yellow","whine"],
				   ["gold","jingle"]]);


var alignment = coopy.compareTables(t1,t2).align();

var data_diff = [];      
var table_diff = new coopy.CoopyTableView(data_diff);

var flags = new coopy.CompareFlags();
var highlighter = new coopy.TableDiff(alignment,flags);
highlighter.hilite(table_diff);

assert(table_diff.height==1);
