var fs = require('fs');
var tmp = require('tmp');
var assert = require('assert');
var daff = require('daff');

tmp.tmpName({ template: 'tmp-XXXXXX.html' },function(err, html1) {
    tmp.tmpName({ template: 'tmp-XXXXXX.tsv' },function(err, tsv1) {
        tmp.tmpName({ template: 'tmp-XXXXXX.csv' },function(err, csv1) {
	    tmp.tmpName({ template: 'tmp-XXXXXX.csv' },function(err, csv2) {
	        if (err) throw err;
	        assert(0==daff.cmd(["diff","data/bridges.csv","data/broken_bridges.csv","--output",tsv1]));
	        assert(0==daff.cmd(["diff","data/bridges.csv","data/broken_bridges.csv","--output",csv1]));
	        assert(0==daff.cmd(["copy",tsv1,csv2]));
	        assert.notEqual(fs.readFileSync(tsv1,"utf-8"),fs.readFileSync(csv1,"utf-8"));
	        assert.equal(fs.readFileSync(csv1,"utf-8"),fs.readFileSync(csv2,"utf-8"));
	        assert(0==daff.cmd(["diff","data/bridges.csv","data/broken_bridges.csv","--output-format","csv","--output",tsv1]));
	        assert.equal(fs.readFileSync(tsv1,"utf-8"),fs.readFileSync(csv1,"utf-8"));
	        assert(0==daff.cmd(["diff","data/bridges.csv","data/broken_bridges.csv","--output-format","html","--output",html1]));
	        assert(fs.readFileSync(html1,"utf-8").indexOf("highlighter")>=0)
	        fs.unlinkSync(tsv1);
	        fs.unlinkSync(csv1);
	        fs.unlinkSync(csv2);
	        fs.unlinkSync(html1);
	    });
        });
    });
});

