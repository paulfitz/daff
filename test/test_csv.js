var fs = require('fs');
var coopy = require('daff');
var assert = require('assert');

var txt = fs.readFileSync("data/quote_me.csv","utf8");
var quote_me = new coopy.SimpleTable(0,0);
new coopy.Csv().parseTable(txt,quote_me);

assert.equal("double \"quotes\" repeated",quote_me.getCell(2,8));
assert.equal("new\nlines",quote_me.getCell(1,5));
assert.equal("and 'embedded'",quote_me.getCell(0,6));

var imf_in = "the IMF's Balance of Payments Manual (BPM6),foo,\"bar\",baz',\"boo\"\"z\"";
var imf_out_expect = "the IMF's Balance of Payments Manual (BPM6),foo,bar,baz',\"boo\"\"z\"";
var imf_table = new coopy.SimpleTable(0,0);
new coopy.Csv().parseTable(imf_in,imf_table);
var imf_out = new coopy.Csv().renderTable(imf_table).replace(/[\n\r]/g, '');
assert.equal(imf_out_expect, imf_out);
