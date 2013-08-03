var fs = require('fs');
var coopy = require('coopyhx');
var tester = require('tester');

{
    var t1 = new coopy.CoopyTableView([["Name","Number"],["John",14],["Jane",99]]);
    var t2 = new coopy.CoopyTableView([["Name","Number"],["Mary",17],["John",14],["Jane",99]]);
    var t3 = new coopy.CoopyTableView([["Name","Number"],["John",15],["Sam",21],["Jane",99]]);
    var t4 = new coopy.CoopyTableView([["Name","Number"],["John",15],["Nimble",88],["Sam",21],["Jane",99]]);
    var t5 = new coopy.CoopyTableView([["Name","Number","Planet"],["John",14,"Earth"],["Jane",99,"Mercury"]]);
    var t6 = new coopy.CoopyTableView([["Name","Planet"],["Frank","Jupiter"],["John","Earth"],["Jane","Mercury"]]);
    var t7 = new coopy.CoopyTableView([["Name","Planet"],["Frank","Jupiter"],["John","Ea->rth"],["Jane","Mercury"]]);
    var t8 = new coopy.CoopyTableView([["Name","Planet"],["Frank","Jupiter"],["John",null],["Jane","Mercury"]]);
    var t9 = new coopy.CoopyTableView([["Name","Planet"],["Frank","Jupiter"],["John","NULL"],["Jane","Mercury"]]);
    var t10 = new coopy.CoopyTableView([["Name","Planet"],["Frank","Jupiter"],["John","_NULL"],["Jane","Mercury"]]);
    var t11 = new coopy.CoopyTableView([["Name","Planet"],["Frank","Jupiter"],["John","Pluto but it is not\na planet anymore"],["Jane","Mercury"]]);
    var t12 = new coopy.CoopyTableView([["Planet"],["Jupiter"],["Pluto but it is not\na planet anymore"],["Mercury"]]);

    var txt = fs.readFileSync("data/quote_me.csv","utf8");
    var quote_me = new coopy.CoopyTableView((new coopy.Csv()).parseTable(txt));
    txt = fs.readFileSync("data/quote_me2.csv","utf8");
    var quote_me2 = new coopy.CoopyTableView((new coopy.Csv()).parseTable(txt));
    txt = fs.readFileSync("data/bridges.csv","utf8");
    var bridges = new coopy.CoopyTableView((new coopy.Csv()).parseTable(txt));

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
	var output = new coopy.CoopyTableView([]);
	td.hilite(output);
    }

    var tables = [t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, quote_me, quote_me2, bridges];
    var names = ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "quote_me", "quote_me2", "bridges"];
    for (var i=0; i<bridges.get_width(); i++) {
	var t = bridges.clone();
	new coopy.TableModifier(t).removeColumn(i);
	tables.push(t);
	names.push("bridges_less_column_" + i);
    }
    var bridges_col0 = bridges.clone();
    bridges_col0.setCell(0,0,"bridger");
    tables.push(bridges_col0);
    names.push("bridges_rename_column_0");
    for (var i in tables) {
	if (!tables.hasOwnProperty(i)) continue;
	for (var j in tables) {
	    if (!tables.hasOwnProperty(j)) continue;
	    tester.round_trip(tables[i],tables[j],names[i] + " -> " + names[j]);
	}
    }
}
