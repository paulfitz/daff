var coopy = require('daff');
var tester = require('tester');

{
    var t1 = new coopy.TableView([["Name","Number"],["John",14],["Jane",99]]);
    var t2 = new coopy.TableView([["Name","Number"],["Mary",17],["John",14],["Jane",99]]);
    var t3 = new coopy.TableView([["Name","Number"],["John",15],["Sam",21],["Jane",99]]);
    
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
}


{
    var t1 = new coopy.TableView([["hdr"],["2009"],["2010"],["2011"],["2012"]]);
    var t2 = new coopy.TableView([["hdr"],["2009"],["2011"],["2012"],["2010"]]);
    var t3 = new coopy.TableView([["hdr"],["2009"],["2010"],["2011"],["2012"]]);
    
    var ct = new coopy.Coopy.compareTables3(t1,t2,t3);
    var align = ct.align();
    tester.order_asserts(align.toOrder(),
			 [[0,0,0],
			  [1,1,1],
			  [2,3,3],
			  [3,4,4],
			  [4,2,2]]);
}

{
    var t1 = new coopy.TableView([["hdr"],["2009"],["2010"],["2011"],["2012"],["2013"]]);
    var t2 = new coopy.TableView([["hdr"],["2009"],["2011"],["2012"],["2010"]]);
    var t3 = new coopy.TableView([["hdr"],["2009"],["2010"],["2011"],["2012"]]);
    
    var ct = new coopy.Coopy.compareTables3(t1,t2,t3);
    var align = ct.align();
    tester.order_asserts(align.toOrder(),
			 [[0,0,0],
			  [1,1,1],
			  [2,3,3],
			  [3,4,4],
			  [4,2,2],
			  [-1,-1,5]]);
    tester.order_asserts(align.meta.toOrder(),
			 [[0,0,0]]);
}
