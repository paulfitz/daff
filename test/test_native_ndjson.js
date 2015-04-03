var fs = require('fs');
var daff = require('daff');
var assert = require('assert');

var d1 = [
    { "Name": "Jane", "Number": 14 },
    { "Name": "John", "Number": 99 }
];

var d2 = [
    { "Name": "Jane", "Number": 14, "Color": "green" },
    { "Name": "John", "Number": 88, "Color": "red" }
];

var t1 = new daff.NdjsonTable(d1);
var t2 = new daff.NdjsonTable(d2);

var flags = new daff.CompareFlags();
flags.allow_nested_cells = true;
var alignment = daff.compareTables(t1,t2,flags).align();
var highlighter = new daff.TableDiff(alignment,flags);
var table_diff = new daff.SimpleTable();
highlighter.hilite(table_diff);

assert.equal(table_diff.get_width(),4);
assert.equal(table_diff.get_height(),4);
assert.equal(table_diff.getCell(0,0),"!");
assert.equal(table_diff.getCell(3,3)["before"],99);
assert.equal(table_diff.getCell(3,3)["after"],88);


var things = [
    {
        key: "t1",
        versions: [
            {
                branch: 'branch1',
                value: { name: "Jane", number: 14 }
            },
            {
                branch: 'branch2',
                value: { name: "Jane", number: 14 }
            }
        ]
    },
    {
        key: "t2",
        versions: [
            {
                branch: 'branch1',
                value: { name: "John", number: 55 }
            },
            {
                branch: 'branch2',
                value: { name: "John", number: 88 }
            }
        ]
    }
];


var thing1 = new daff.NdjsonTable(things,function(row) {
    return row["versions"][0]["value"];
});

var thing2 = new daff.NdjsonTable(things,function(row) {
    return row["versions"][1]["value"];
});


var alignment = daff.compareTables(thing1,thing2,flags).align();
var highlighter = new daff.TableDiff(alignment,flags);
var table_diff = new daff.SimpleTable();
highlighter.hilite(table_diff);

assert.equal(table_diff.get_width(),3);
assert.equal(table_diff.get_height(),3);
assert.equal(table_diff.getCell(2,2)["before"],55);
assert.equal(table_diff.getCell(2,2)["after"],88);
