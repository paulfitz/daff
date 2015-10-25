var assert = require('assert');
var daff = require('daff');
var data1 = [
    ['Country','Capital'],
    ['Ireland','Dublin'],
    ['France','Paris'],
    ['Spain','Barcelona']
];
var data2 = [
    ['Country','Code','Capital'],
    ['Ireland','ie','Dublin'],
    ['France','fr','Paris'],
    ['Spain','es','Madrid'],
    ['Germany','de','Berlin']
];

// older, complicated example
var table1 = new daff.TableView(data1);
var table2 = new daff.TableView(data2);
var alignment = daff.compareTables(table1,table2).align();
var data_diff = [];
var table_diff = new daff.TableView(data_diff);
var flags = new daff.CompareFlags();
var highlighter = new daff.TableDiff(alignment,flags);
highlighter.hilite(table_diff);
assert(table_diff.height==6);
assert(table_diff.width==4);

// newer, streamlined example
var table_diff = daff.diff(data1,data2);
assert(table_diff.height==6);
assert(table_diff.width==4);

