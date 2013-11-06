var fs = require('fs');
var coopy = require('coopyhx');
var assert = require('assert');

function check_break(x,y,len) {
    var td = new coopy.TextDiff();
    var result = td.diff(x,y);
    console.log(result);
    assert(result.length == len);
}

function check_speed(x,y) {
    var td = new coopy.TextDiff();
    var result = td.diff(x,y);
    console.log(result);
}

check_break("you wish i knew where i was",
	    "i wish i knew where you were",
	    5);

check_break("101","102",2);

check_break("101000","101001",3);

check_break("401001","101001",3);

check_break("401001","101006",5);

check_break("401901","101006",2);

var core = "this is going to repeat a lot I am afraid! ";
var local = "";
for (var i=0; i<1000; i++) {
    local += core;
}
var remote = core + "x" + local;

// NOT READY FOR THIS YET!
//check_speed(local,remote);
