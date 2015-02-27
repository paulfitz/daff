var fs = require('fs');
var coopy = require('daff');
var tester = require('tester');
var assert = require('assert');

var bridges = tester.readCsv("data/bridges.csv");
var broken_bridges = tester.readCsv("data/broken_bridges.csv");

function checkMatch(fname,align,options) {
    var td = new coopy.TableDiff(align,options);
    var output = new coopy.TableView([]);
    td.hilite(output);
    var dr = new coopy.DiffRender();
    dr.render(output);
    var got = dr.html();
    var ref = fs.readFileSync(fname,"utf8");
    ref.replace(/[ \"\'\n\r]/g,"");
    got.replace(/[ \"\'\n\r]/g,"");
    if (ref!=got) {
	console.log("mismatch against " + fname);
    }
    assert(ref==got);
}

var ct = new coopy.compareTables(broken_bridges,bridges);
var align = ct.align();
var options = new coopy.CompareFlags();	
checkMatch("data/bridges_diff.html",align,options);

options.always_show_order = true;
options.never_show_order = false;
checkMatch("data/bridges_diff_show_index.html",align,options);

options.count_like_a_spreadsheet = false;
checkMatch("data/bridges_diff_show_index_ncol.html",align,options);
options.count_like_a_spreadsheet = true;

var broken_bridges_without_length = broken_bridges.clone();
new coopy.TableModifier(broken_bridges_without_length).removeColumn(2);
ct = new coopy.compareTables(broken_bridges_without_length,bridges);
align = ct.align();
checkMatch("data/bridges_diff_add_column.html",align,options);

options.count_like_a_spreadsheet = false;
checkMatch("data/bridges_diff_add_column_ncol.html",align,options);
