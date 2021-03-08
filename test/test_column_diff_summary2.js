var daff = require('../lib/daff.js');
var assert = require('assert');


var tableA = [
    { "Name": "", "Number": '14', "Color": "green" },
    { "Name": "John1", "Number": '88', "Color": "red" },
    { "Name": "John1", "Number": '88', "Color": "red" },
    { "Name": "John2", "Number": '99', "Color": '22' },
    { "Name": "John3", "Number": '99', "Color": '23' },
    { "Name": "John4", "Number": '99', "Color": '' },
    { "Name": "John5", "Number": '99', "Color": '25' },
    { "Name": "John43", "Number": '99', "Color": '28' },
    { "Name": "John5", "Number": '991', "Color": '28' },
    { "Name": "John6", "Number": '992', "Color": '281' },
    { "Name": "John7", "Number": '993', "Color": '282' },
    { "Name": "John8", "Number": '994', "Color": '283' },
];

var tableB = [
    { "Name": "Jane", "Number": '14', "Color": "green" },
    { "Name": "John1", "Number": '88', "Color": "red" },
    { "Name": "John2", "Number": '99', "Color": '22' },
    { "Name": "John3", "Number": '99', "Color": '23' },
    { "Name": "John4", "Number": '99', "Color": '28' },
    { "Name": "", "Number": '99', "Color": '25' },
    { "Name": "John43", "Number": '99', "Color": '28' },
    { "Name": "John55", "Number": '991', "Color": '28' },
    { "Name": "John6", "Number": '992', "Color": '281' },
    { "Name": "", "Number": '993', "Color": '282' },
    { "Name": "John8", "Number": '994', "Color": '283' },
    { "Name": "John8", "Number": '994', "Color": '283' },
];

const daffTableA = new daff.NdjsonTable(tableA);
const daffTableB = new daff.NdjsonTable(tableB);
var dataDiff = [];
var tableDiff = new daff.TableView(dataDiff);

var alignment = daff.compareTables(daffTableA, daffTableB).align();

var flags = new daff.CompareFlags();
flags.allow_nested_cells = true;
flags.ignore_whitespace = true;
flags.always_show_order = false;
flags.never_show_order = true;


var highlighter = new daff.TableDiff(alignment, flags);
highlighter.hilite(tableDiff);


var diff2html = new daff.DiffRender();
diff2html.render(tableDiff);
require('fs').writeFileSync('./test-diff.html',

    '<style>' + diff2html.sampleCss() + '</style>' +
    '<pre style="width: 100%; height: 600px; overflow: scroll">' + JSON.stringify(highlighter.getSummary(), null, 2)+ '</pre>' +
    '<div class="highlighter">' + diff2html.html() + '</div>'

    , { encoding: 'utf8' });

