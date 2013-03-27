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
    assert(lst.length == lst2.length, "list length " + lst.length + " " + lst2.length);
    for (var i=0; i<lst.length; i++) {
	var pair = lst[i];
	var pair2 = lst2[i];
	assert(pair[0]==pair2.l,txt);
	assert(pair[1]==pair2.r,txt);
    }
}

{
    var t1 = new jtable.JTable2([["Name","Number"],["John",14]]);
    var t2 = new jtable.JTable2([["Name","Number"],["Mary",17],["John",15]]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    align_asserts(align,
		  [[0,0],[1,2],[null,1]]);
}


{
    var t1 = new jtable.JTable2([
	["Name","Number","Web"],
	["John",1442,null],
	["Mary",null,"www.mary.none"],
	["Sam",null,null],
    ]);
    var t2 = new jtable.JTable2([
	["Name","Number","Web"],
	["John",1443,null],
	["Mary",null,"www.mary.none"],
	["Sam",null,null],
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    align_asserts(align,
		  [[0,0],[1,1],[2,2],[3,3]]);
}


{
    var t1 = new jtable.JTable2([
	["Name","Number","Web"],
	["John",1443,null],
	["Mary",null,"www.mary.none"],
	["Sam",null,null],
	["John",1992,null]
    ]);
    var t2 = new jtable.JTable2([
	["Name","Number","Web"],
	["John",1443,null],
	["Mary",null,"www.mary.no"],
	["Sam",null,null], 
	["John",1992,"www.john.none"]
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    align_asserts(align,
		  [[0,0],[1,1],[2,2],[3,3],[4,4]]);
}



{
    var t1 = new jtable.JTable2([
	["Name","Number","Web"],
	["John",1443,null],
	["Mary",null,"www.mary.none"],
	["Sam",null,null],
	["John",1992,null]
    ]);
    var t2 = new jtable.JTable2([
	["Name","Number","Web"],
	["John",1443,null],
	["Mary",null,"www.mary.no"],
	["Sam",null,null], 
	["John",1992,"www.john.none"],
	["John",1992,"www.john.none"]
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    align_asserts(align,
		  [[0,0],[1,1],[2,2],[3,3],[4,null]]);
}


{
    var t1 = new jtable.JTable2([
	["Year","Number"],
	[2009,0],
	[2011,4],
	[2012,2]
    ]);
    var t2 = new jtable.JTable2([
	["Year","Number"],
	[2009,0],
	[2010,5],
	[2012,2],
	[2011,4]
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    align_asserts(align,
		  [[0,0],[1,1],[2,4],[3,3]]);
    order_asserts(align.toOrder(),
		  [[0,0],[1,1],[-1,2],[3,3],[2,4]]);
}


{
    var t1 = new jtable.JTable2([
	["Year","Number"],
	[2009,0],
	[2011,4],
	[2012,""]
    ]);
    var t2 = new jtable.JTable2([
	["Year","Number"],
	[2009,0],
	[2011,4],
	[2019,""],
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    order_asserts(align.toOrder(),
		  [[0,0],[1,1],[2,2],[-1,3],[3,-1]]);
}

