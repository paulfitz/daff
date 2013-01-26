// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class Coopy {
    public static function main() : Int {
        var st : SimpleTable = new SimpleTable(15,6);
        var tab : Table = st;
        var bag : Bag = st;
        trace("table size is " + tab.width + "x" + tab.height);
        tab.set_cell(3,4,new SimpleCell(33));
        trace("element is " + tab.get_cell(3,4));

        trace("table as bag is " + bag);
        var datum : Datum = bag.get_item(4);
        var row : Bag = bag.get_item(4).bag;
        trace("element is " + row.get_item(3));

        var compare : Compare = new Compare();
        var d1 : Datum = new SimpleCell(10);
        var d2 : Datum = new SimpleCell(10);
        var d3 : Datum = new SimpleCell(20);
        var report : Report = new Report();
        compare.compare(d1,d2,d3,report);
        trace("report is " + report);
        d2 = new SimpleCell(50);
        report.clear();
        compare.compare(d1,d2,d3,report);
        trace("report is " + report);
        d2 = new SimpleCell(20);
        report.clear();
        compare.compare(d1,d2,d3,report);
        trace("report is " + report);
        d1 = new SimpleCell(20);
        report.clear();
        compare.compare(d1,d2,d3,report);
        trace("report is " + report);

        return 0;
    }

    public static function show(t: Table) : Void {
        var w : Int = t.width;
        var h : Int = t.height;
        var txt : String = "";
        for (y in 0...h) {
            for (x in 0...w) {
                txt += t.get_cell(x,y);
                txt += " ";
            }
            txt += "\n";
        }
        trace(txt);
    }
}
