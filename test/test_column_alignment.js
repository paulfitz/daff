var coopy = require('coopy');
var assert = require('assert');
var jtable = require('jtable');

function order_asserts(order,lst) {
    var lst2 = order.getList();
    var txt = order.toString();
    assert(lst.length == lst2.length, "list length " + lst.length + " " + lst2.length + " " + order.toString());
    for (var i=0; i<lst.length; i++) {
	var pair = lst[i];
	var pair2 = lst2[i];
	assert(pair[0]==pair2.l,txt);
	assert(pair[1]==pair2.r,txt);
    }
}

{
    var t1 = new jtable.JTable2([
	["Year","Number"],
	[2009,0],
	[2011,4],
	[2012,""]
    ]);
    var t2 = new jtable.JTable2([
	["Year","Number","More"],
	[2009,0,20],
	[2011,4,30],
	[2019,"",40],
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    order_asserts(align.meta.toOrder(),
		  [[0,0],[1,1],[-1,2]]);
    order_asserts(align.toOrder(),
		  [[0,0],[1,1],[2,2],[-1,3],[3,-1]]);
}

{
    var t1 = new jtable.JTable2([
	["Year","Number","More"],
	[2009,0,20],
	[2011,4,30],
	[2019,"",40],
    ]);
    var t2 = new jtable.JTable2([
	["Year","Number"],
	[2009,0],
	[2011,4],
	[2012,""]
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    order_asserts(align.meta.toOrder(),
		  [[0,0],[1,1],[2,-1]]);
    order_asserts(align.toOrder(),
		  [[0,0],[1,1],[2,2],[-1,3],[3,-1]]);
}



{
    var t1 = new jtable.JTable2([
	["Number","More","Year"],
	[0,20,2009],
	[4,30,2011],
	["",40,2019],
    ]);
    var t2 = new jtable.JTable2([
	["Year","Number"],
	[2009,0],
	[2011,4],
	[2012,""]
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    order_asserts(align.meta.toOrder(),
		  [[2,0],[0,1],[1,-1]]);
    order_asserts(align.toOrder(),
		  [[0,0],[1,1],[2,2],[-1,3],[3,-1]]);
}


