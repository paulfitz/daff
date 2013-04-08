var fs = require('fs');
var coopy = require('coopy');
var jtable = require('jtable');
var tester = require('tester');

{
    var t1 = new jtable.JTable2([["Name","Number"],["John",14],["Jane",99]]);
    var t2 = new jtable.JTable2([["Name","Number"],["Mary",17],["John",14],["Jane",99]]);
    var t3 = new jtable.JTable2([["Name","Number"],["John",15],["Sam",21],["Jane",99]]);
    var t4 = new jtable.JTable2([["Name","Number"],["John",15],["Nimble",88],["Sam",21],["Jane",99]]);
    var t5 = new jtable.JTable2([["Name","Number","Planet"],["John",14,"Earth"],["Jane",99,"Mercury"]]);
    var t6 = new jtable.JTable2([["Name","Planet"],["Frank","Jupiter"],["John","Earth"],["Jane","Mercury"]]);
    var t7 = new jtable.JTable2([["Name","Planet"],["Frank","Jupiter"],["John","Ea->rth"],["Jane","Mercury"]]);
    var t8 = new jtable.JTable2([["Name","Planet"],["Frank","Jupiter"],["John",null],["Jane","Mercury"]]);
    var t9 = new jtable.JTable2([["Name","Planet"],["Frank","Jupiter"],["John","NULL"],["Jane","Mercury"]]);
    var t10 = new jtable.JTable2([["Name","Planet"],["Frank","Jupiter"],["John","_NULL"],["Jane","Mercury"]]);
    var t11 = new jtable.JTable2([["Name","Planet"],["Frank","Jupiter"],["John","Pluto but it is not\na planet anymore"],["Jane","Mercury"]]);
    var t12 = new jtable.JTable2([["Planet"],["Jupiter"],["Pluto but it is not\na planet anymore"],["Mercury"]]);

    var txt = fs.readFileSync("data/quote_me.csv","utf8");
    var quote_me = new jtable.JTable2((new coopy.Csv()).parseTable(txt));
    txt = fs.readFileSync("data/quote_me2.csv","utf8");
    var quote_me2 = new jtable.JTable2((new coopy.Csv()).parseTable(txt));
    txt = fs.readFileSync("data/bridges.csv","utf8");
    var bridges = new jtable.JTable2((new coopy.Csv()).parseTable(txt));

    {
	var ct = new coopy.Coopy.compareTables3(t1,t2,t3);
	var align = ct.align();
	tester.align_asserts(align,
			     [[0,0],[1,1],[2,3]]);
	tester.align_asserts(align.reference,
			     [[0,0],[1,2],[2,3]]);
	tester.order_asserts(align.toOrder(),
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

    var tables = [t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12];
    var names = ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"];
    for (var i in tables) {
	for (var j in tables) {
	    tester.round_trip(tables[i],tables[j],names[i] + " -> " + names[j]);
	}
    }

    tables = [quote_me, quote_me2];
    names = ["quote_me", "quote_me2"];
    for (var i in tables) {
	for (var j in tables) {
	    tester.round_trip(tables[i],tables[j],names[i] + " -> " + names[j]);
	}
    }

    tables = [bridges];
    names = ["bridges"];
    for (var i=0; i<bridges.get_width(); i++) {
	var t = bridges.clone();
	new coopy.TableModifier(t).removeColumn(i);
	tables.push(t);
	names.push("bridges_less_column_" + i);
    }
    for (var i in tables) {
	for (var j in tables) {
	    tester.round_trip(tables[i],tables[j],names[i] + " -> " + names[j]);
	}
    }

    var bridges_col0 = bridges.clone();
    bridges_col0.setCell(0,0,"bridger");
    tester.round_trip(bridges,bridges_col0,"change column name");
}
