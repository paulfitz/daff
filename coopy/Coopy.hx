// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

class Coopy {
    static public function compareTables(t1: Table, t2: Table) : CompareTable {
        var ct: CompareTable = new CompareTable();
        var comp : TableComparisonState = new TableComparisonState();
        comp.a = t1;
        comp.b = t2;
        ct.attach(comp);
        return ct;
    }

    static public function compareTables3(t1: Table, t2: Table, t3: Table) : CompareTable {
        var ct: CompareTable = new CompareTable();
        var comp : TableComparisonState = new TableComparisonState();
        comp.p = t1;
        comp.a = t2;
        comp.b = t3;
        ct.attach(comp);
        return ct;
    }


    public static function main() : Int {
        var st : SimpleTable = new SimpleTable(15,6);
        var tab : Table = st;
        var bag : Bag = st;
        trace("table size is " + tab.width + "x" + tab.height);
        tab.setCell(3,4,new SimpleCell(33));
        trace("element is " + tab.getCell(3,4));

        trace("table as bag is " + bag);
        var datum : Datum = bag.getItem(4);
        var row : Bag = bag.getItemView().getBag(datum);
        trace("element is " + row.getItem(3));

        var compare : Compare = new Compare();
        var d1 : ViewedDatum = ViewedDatum.getSimpleView(new SimpleCell(10));
        var d2 : ViewedDatum = ViewedDatum.getSimpleView(new SimpleCell(10));
        var d3 : ViewedDatum = ViewedDatum.getSimpleView(new SimpleCell(20));
        var report : Report = new Report();
        compare.compare(d1,d2,d3,report);
        trace("report is " + report);
        d2 = ViewedDatum.getSimpleView(new SimpleCell(50));
        report.clear();
        compare.compare(d1,d2,d3,report);
        trace("report is " + report);
        d2 = ViewedDatum.getSimpleView(new SimpleCell(20));
        report.clear();
        compare.compare(d1,d2,d3,report);
        trace("report is " + report);
        d1 = ViewedDatum.getSimpleView(new SimpleCell(20));
        report.clear();
        compare.compare(d1,d2,d3,report);
        trace("report is " + report);

        var tv : TableView = new TableView();

        var comp : TableComparisonState = new TableComparisonState();
        var ct : CompareTable = new CompareTable();
        comp.a = st;
        comp.b = st;
        ct.attach(comp);

        trace("comparing tables");
        var t1 : SimpleTable = new SimpleTable(3,2);
        var t2 : SimpleTable = new SimpleTable(3,2);
        var t3 : SimpleTable = new SimpleTable(3,2);
        var dt1 : ViewedDatum = new ViewedDatum(t1,new TableView());
        var dt2 : ViewedDatum = new ViewedDatum(t2,new TableView());
        var dt3 : ViewedDatum = new ViewedDatum(t3,new TableView());
        compare.compare(dt1,dt2,dt3,report);
        trace("report is " + report);
        t3.setCell(1,1,new SimpleCell("hello"));
        compare.compare(dt1,dt2,dt3,report);
        trace("report is " + report);
        t1.setCell(1,1,new SimpleCell("hello"));
        compare.compare(dt1,dt2,dt3,report);
        trace("report is " + report);

        var v : Viterbi = new Viterbi();
        var td : TableDiff = new TableDiff(null);
        var idx : Index = new Index();

        return 0;
    }

    public static function show(t: Table) : Void {
        var w : Int = t.width;
        var h : Int = t.height;
        var txt : String = "";
        for (y in 0...h) {
            for (x in 0...w) {
                txt += t.getCell(x,y);
                txt += " ";
            }
            txt += "\n";
        }
        trace(txt);
    }
}
