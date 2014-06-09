var fs = require('fs');
var coopy = require('daff');
var tester = require('tester');
var assert = require('assert');

var bridges = tester.readCsv("data/bridges.csv");
var broken_bridges = tester.readCsv("data/broken_bridges.csv");

var ct = new coopy.compareTables(broken_bridges,bridges);
var align = ct.align();
var options = new coopy.CompareFlags();	
var td = new coopy.TableDiff(align,options);
var output = new coopy.TableView([]);
td.hilite(output);
var dr = new coopy.DiffRender();
dr.render(output);
var got = dr.html();
var ref = fs.readFileSync("data/bridges_diff.html","utf8");
ref.replace(/[ \"\'\n\r]/g,"");
got.replace(/[ \"\'\n\r]/g,"");
assert(ref==got);

