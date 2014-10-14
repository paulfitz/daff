var daff = require('daff');
var assert = require('assert');
var tester = require('tester');

var t1 = tester.readCsv("data/waffle.csv");
var t2 = tester.readCsv("data/waffle2.csv");

{
    var ct = new daff.compareTables(t1,t2);
    var align = ct.align();
    var options = new daff.CompareFlags();
    options.show_unchanged = true;
    var td = new daff.TableDiff(align,options);
    var output = new daff.TableView([]);
    td.hilite(output);

    var desired = new daff.TableView([[ '@@', 'id', 'color' ],
				      [ '', '15', 'red' ],
				      [ '', '13', 'mauve' ],
				      [ '', '15', 'red' ],
				      [ '', '15', 'red' ],
				      [ '', '15', 'red' ],
				      [ '+++', '16', 'green' ],
				      [ '', '15', 'red' ],
				      [ '', '15', 'red' ],
				      [ '', '15', 'red' ],
				      [ '', '15', 'red' ],
				      [ '', '15', 'red' ]]);

    assert.equal(output.toString(),desired.toString());
}

