var assert = require('assert');
var daff = require('daff');
var tmp = require('tmp');

tmp.tmpName({ template: 'tmp-XXXXXX.csv' },function(err, csv) {
  if (err) throw err;
  assert(0==daff.cmd(["diff","data/bridges.csv","data/broken_bridges.csv","--output",csv]));
  assert(0==daff.cmd(["diff","data/bridges.csv","data/bridges.csv","--output",csv]));
  assert(1==daff.cmd(["diff","--fail-if-diff","data/bridges.csv","data/broken_bridges.csv","--output",csv]));
  assert(0==daff.cmd(["diff","--fail-if-diff","data/bridges.csv","data/bridges.csv","--output",csv]));
  assert(2==daff.cmd(["diff","--fail-if-diff","data/bridges.csv","data/nothing.csv","--output",csv]));
});
