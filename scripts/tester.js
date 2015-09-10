var assert = require('assert');
var coopy = require('daff');
var fs = require('fs');

function order_asserts(order,lst) {
    var lst2 = order.getList();
    var txt = order.toString();
    assert(lst.length == lst2.length, "list length " + lst.length + " " + lst2.length + " " + order.toString());
    for (var i=0; i<lst.length; i++) {
	var pair = lst[i];
	var pair2 = lst2[i];
	var txti = txt + " checking " + pair.toString() + " " + pair2.toString();
	assert(pair[0]==pair2.l,txti);
	assert(pair[1]==pair2.r,txti);
	if (pair[2]!=null) {
	    assert(pair[2]==pair2.p,txti);
	}
    }
}

function align_assert(align,a,b) {
    var msg = "alignment " + align + " " + a + " -> " + b;
    if (a==null) {
	assert(align.b2a(b)==-1,msg);
    } else {
        if (b==null) b = -1;
	assert(align.a2b(a)==b,msg);
    }
}

function align_asserts(align,lst) {
    for (var i=0; i<lst.length; i++) {
	var pair = lst[i];
	align_assert(align,pair[0],pair[1]);
    }
}


function round_trip_with_flags(t1,t2,msg,flags) {
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    var td = new coopy.TableDiff(align,flags);
    var output = new coopy.TableView([]);
    td.hilite(output);
    
    var t1c = t1.clone();
    var patcher = new coopy.HighlightPatch(t1c,output);
    patcher.apply();
    if (false) {
	console.log("====================================");
	console.log(msg);
	console.log(t1);
	console.log(t2);
	console.log(t1c);
	console.log(output);
    }
    assert(coopy.SimpleTable.tableIsSimilar(t1c,t2),msg);
}

function round_trip(t1,t2,msg) {
    var flags = new coopy.CompareFlags();
    round_trip_with_flags(t1,t2,msg,flags);
}

function bi_round_trip(t1,t2,msg) {
    round_trip(t1,t2,msg);
    round_trip(t2,t1,msg + " (reversed)");
}

function readCsv(fname) {
    var txt = fs.readFileSync(fname,"utf8");
    var result = new coopy.TableView([]);
    (new coopy.Csv()).parseTable(txt,result);
    return result;
}


exports.align_assert = align_assert;
exports.align_asserts = align_asserts;
exports.order_asserts = order_asserts;
exports.round_trip_with_flags = round_trip_with_flags;
exports.round_trip = round_trip;
exports.bi_round_trip = bi_round_trip;
exports.readCsv = readCsv;


