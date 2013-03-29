var coopy = require('coopy_node');
var assert = require('assert');
var jtable = require('jtable');

function align_assert(align,a,b) {
    var msg = "alignment " + align + " " + a + " -> " + b;
    if (a==null) {
	assert(align.b2a(b)==null,msg);
    } else {
	assert(align.a2b(a)==b,msg);
    }
}

function align_asserts(align,lst) {
    for (var i=0; i<lst.length; i++) {
	var pair = lst[i];
	align_assert(align,pair[0],pair[1]);
    }
}

function order_asserts(order,lst) {
    var lst2 = order.getList();
    var txt = order.toString();
    assert(lst.length == lst2.length);
    for (var i=0; i<lst.length; i++) {
	var grp = lst[i];
	var grp2 = lst2[i];
	var txti = txt + " checking " + grp.toString() + " " + grp2.toString();
	assert(grp[0]==grp2.l,txti);
	assert(grp[1]==grp2.r,txti);
	assert(grp[2]==grp2.p,txti);
    }
}

function round_trip(t1,t2,msg) {
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    var flags = new coopy.CompareFlags();
    var td = new coopy.TableDiff(align,flags);
    var output = new jtable.JTable2([]);
    td.hilite(output);
    
    var t1c = t1.clone();
    var patcher = new coopy.HighlightPatch(t1c,output);
    patcher.apply();
    assert(t1c.isSimilar(t2),msg);
}

function bi_round_trip(t1,t2,msg) {
    round_trip(t1,t2,msg);
    round_trip(t2,t1,msg + " (reversed)");
}

{
    var t1 = new jtable.JTable2([["Name","Number"],["John",14],["Jane",99]]);
    var t2 = new jtable.JTable2([["Name","Number"],["Mary",17],["John",14],["Jane",99]]);
    var t3 = new jtable.JTable2([["Name","Number"],["John",15],["Sam",21],["Jane",99]]);
    var t4 = new jtable.JTable2([["Name","Number"],["John",15],["Nimble",88],["Sam",21],["Jane",99]]);
    
    {
	var ct = new coopy.Coopy.compareTables3(t1,t2,t3);
	var align = ct.align();
	align_asserts(align,
		      [[0,0],[1,1],[2,3]]);
	align_asserts(align.reference,
		      [[0,0],[1,2],[2,3]]);
	order_asserts(align.toOrder(),
		      [[0,0,0],
		       [1,-1,-1],
		       [2,1,1],
		       [-1,2,-1],
		       [3,3,2]]);

	var options = new coopy.CompareFlags();
	var td = new coopy.TableDiff(align,options);
	var output = new jtable.JTable2([]);
	td.hilite(output);
    }

    var tables = [t1, t2, t3, t4];
    for (var i in tables) {
	for (var j in tables) {
	    round_trip(tables[i],tables[j],"t" + i + " <-> t" + j);
	}
    }
}
