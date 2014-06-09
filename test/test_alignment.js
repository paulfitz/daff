var coopy = require('daff');
var tester = require('tester');

{
    var t1 = new coopy.TableView([["Name","Number"],["John",14]]);
    var t2 = new coopy.TableView([["Name","Number"],["Mary",17],["John",15]]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    tester.align_asserts(align,
			 [[0,0],[1,2],[null,1]]);
}


{
    var t1 = new coopy.TableView([
	["Name","Number","Web"],
	["John",1442,null],
	["Mary",null,"www.mary.none"],
	["Sam",null,null],
    ]);
    var t2 = new coopy.TableView([
	["Name","Number","Web"],
	["John",1443,null],
	["Mary",null,"www.mary.none"],
	["Sam",null,null],
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    tester.align_asserts(align,
			 [[0,0],[1,1],[2,2],[3,3]]);
}


{
    var t1 = new coopy.TableView([
	["Name","Number","Web"],
	["John",1443,null],
	["Mary",null,"www.mary.none"],
	["Sam",null,null],
	["John",1992,null]
    ]);
    var t2 = new coopy.TableView([
	["Name","Number","Web"],
	["John",1443,null],
	["Mary",null,"www.mary.no"],
	["Sam",null,null], 
	["John",1992,"www.john.none"]
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    tester.align_asserts(align,
			 [[0,0],[1,1],[2,2],[3,3],[4,4]]);
}



{
    var t1 = new coopy.TableView([
	["Name","Number","Web"],
	["John",1443,null],
	["Mary",null,"www.mary.none"],
	["Sam",null,null],
	["John",1992,null]
    ]);
    var t2 = new coopy.TableView([
	["Name","Number","Web"],
	["John",1443,null],
	["Mary",null,"www.mary.no"],
	["Sam",null,null], 
	["John",1992,"www.john.none"],
	["John",1992,"www.john.none"]
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    tester.align_asserts(align,
			 [[0,0],[1,1],[2,2],[3,3],[4,null]]);
}


{
    var t1 = new coopy.TableView([
	["Year","Number"],
	[2009,0],
	[2011,4],
	[2012,2]
    ]);
    var t2 = new coopy.TableView([
	["Year","Number"],
	[2009,0],
	[2010,5],
	[2012,2],
	[2011,4]
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    tester.align_asserts(align,
			 [[0,0],[1,1],[2,4],[3,3]]);
    tester.order_asserts(align.toOrder(),
			 [[0,0],[1,1],[-1,2],[3,3],[2,4]]);
}


{
    var t1 = new coopy.TableView([
	["Year","Number"],
	[2009,0],
	[2011,4],
	[2012,""]
    ]);
    var t2 = new coopy.TableView([
	["Year","Number"],
	[2009,0],
	[2011,4],
	[2019,""],
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    tester.order_asserts(align.toOrder(),
			 [[0,0],[1,1],[2,2],[-1,3],[3,-1]]);
}

