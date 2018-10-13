var fs = require('fs');
var coopy = require('daff');
var tester = require('tester');
var assert = require('assert');

var options = new coopy.CompareFlags();	
var v1 = tester.readCsv("data/wide1.csv");
var v2 = tester.readCsv("data/wide2.csv");

// make sure that a wide diff, when configured to be shown in default mode, has no space
var ct = new coopy.compareTables(v1,v2);
var td = new coopy.TableDiff(ct.align(),options);
var output = new coopy.TableView([]);
td.hilite(output);
var render = new coopy.TerminalDiffRender(options);
var txt = render.render(output).replace(/[^ a-z+\-,\n]/g, '').replace(/m/g,'');
assert.equal(txt.indexOf('  ,thing'),-1);

// make sure that a wide diff, when configured to be shown in sparse mode, contains space
options.padding_strategy = "sparse";
ct = new coopy.compareTables(v1,v2);
td = new coopy.TableDiff(ct.align(),options);
output = new coopy.TableView([]);
td.hilite(output);
render = new coopy.TerminalDiffRender(options);
txt = render.render(output).replace(/[^ a-z+\-,\n]/g, '').replace(/m/g,'');
assert.notEqual(txt.indexOf('  ,thing'),-1);

