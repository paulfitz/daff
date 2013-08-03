var fs = require('fs');
var coopy = require('coopyhx');
var assert = require('assert');
var tester = require('tester');

{
    var t1 = new coopy.CoopyTableView([]);
    var t2 = new coopy.CoopyTableView([["!","+++","+++",],["@@","A","B"],["+++","hi","there"]]);
    var t3 = new coopy.CoopyTableView([]);
    var patcher = new coopy.HighlightPatch(t3,t2);
    patcher.apply();
    assert(t3.get_width()==2);
    assert(t3.get_height()==2);
}
