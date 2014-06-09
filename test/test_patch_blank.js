var fs = require('fs');
var coopy = require('daff');
var assert = require('assert');
var tester = require('tester');

{
    var t1 = new coopy.TableView([]);
    var t2 = new coopy.TableView([["!","+++","+++",],["@@","A","B"],["+++","hi","there"]]);
    var t3 = new coopy.TableView([]);
    var patcher = new coopy.HighlightPatch(t3,t2);
    patcher.apply();
    assert(t3.get_width()==2);
    assert(t3.get_height()==2);
}
