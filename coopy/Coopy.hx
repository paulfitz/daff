// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

class Coopy {
    static public function compareTables(local: Table, remote: Table) : CompareTable {
        var ct: CompareTable = new CompareTable();
        var comp : TableComparisonState = new TableComparisonState();
        comp.a = local;
        comp.b = remote;
        ct.attach(comp);
        return ct;
    }

    static public function compareTables3(parent: Table, local: Table, remote: Table) : CompareTable {
        var ct: CompareTable = new CompareTable();
        var comp : TableComparisonState = new TableComparisonState();
        comp.p = parent;
        comp.a = local;
        comp.b = remote;
        ct.attach(comp);
        return ct;
    }

    static private function randomTests() : Int {
        // disorganized tests from a bygone era.

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
        var td : TableDiff = new TableDiff(null,null);
        var idx : Index = new Index();
        var dr : DiffRender = new DiffRender();
        var cf : CompareFlags = new CompareFlags();

        return 0;
    }

#if cpp
    private static function saveTable(name: String, t: Table) : Bool {
        var csv : Csv = new Csv();
        var txt : String = csv.renderTable(t);
        //var txt : String = haxe.Json.stringify(jsonify(t));
        if (name!="-") {
            sys.io.File.saveContent(name,txt);
        } else {
            Sys.stdout().writeString(txt);
        }
        return true;
    }

    private static function jsonToTable(json: Dynamic) : Table {
        var output : Table = null;
        for (name in Reflect.fields(json)) {
            var t = Reflect.field(json,name);
            var columns : Array<String> = Reflect.field(t,"columns");
            if (columns==null) continue;
            var rows : Array<Dynamic> = Reflect.field(t,"rows");
            if (rows==null) continue;
            output = new SimpleTable(columns.length,rows.length);
            var has_hash : Bool = false;
            var has_hash_known : Bool = false;
            for (i in 0...rows.length) {
                var row = rows[i];
                if (!has_hash_known) {
                    if (Reflect.fields(row).length == columns.length) {
                        has_hash = true;
                    }
                    has_hash_known = true;
                }
                if (!has_hash) {
                    var lst : Array<Dynamic> = cast row;
                    for (j in 0...columns.length) {
                        var val = lst[j];
                        //output.setCell(j,i,val);
                        output.setCell(j,i,new SimpleCell(val));
                    }
                } else {
                    for (j in 0...columns.length) {
                        var val = Reflect.field(row,columns[j]);
                        //output.setCell(j,i,val);
                        output.setCell(j,i,new SimpleCell(val));
                    }
                }
            }
        }
        return output;
    }

    private static function loadTable(name: String) : Table {
        var txt : String = sys.io.File.getContent(name);
        try {
            var json = haxe.Json.parse(txt);
            return jsonToTable(json);
        } catch (e: Dynamic) {
            var csv : Csv = new Csv();
            var data : Array<Array<String>> = csv.parseTable(txt);
            var h : Int = data.length;
            var w : Int = 0;
            if (h>0) w = data[0].length;
            var output = new SimpleTable(w,h);
            for (i in 0...h) {
                for (j in 0...w) {
                    var val : String = data[i][j];
                    output.setCell(j,i,new SimpleCell(val));
                }
            }
            return output;
        }
    }

    public static function sysMain() : Int {
        var args : Array<String> = Sys.args();

        if (args[0] == "--test") {
            return randomTests();
        }

        var more : Bool = true;
        var output : String = null;
        while (more) {
            more = false;
            for (i in 0...args.length) {
                if (args[i]=="--output") {
                    more = true;
                    output = args[i+1];
                    args.splice(i,2);
                    break;
                }
            }
        }
        if (args.length != 3 || args[0] != "diff") {
            Sys.stderr().writeString("Howdy.  coopyhx doesn't have much of a command line interface.\n");
            Sys.stderr().writeString("You may want the coopy toolbox https://github.com/paulfitz/coopy\n");
            Sys.stderr().writeString("If you do want coopyhx - call as:\n");
            Sys.stderr().writeString("  coopyhx diff [--output OUTPUT.jsonbook] a.jsonbook b.jsonbook\n");
            return 1;
        }
        if (output == null) {
            output = "-";
        }
        var a = loadTable(args[1]);
        var b = loadTable(args[2]);
        var ct : CompareTable = compareTables(a,b);
        var align : Alignment = ct.align();
        var flags : CompareFlags = new CompareFlags();
        //flags.show_unchanged = true;
        flags.always_show_header = true;
        var td : TableDiff = new TableDiff(align,flags);
        var o = new SimpleTable(0,0);
        td.hilite(o);
        saveTable(output,o);
        return 0;
    }
#end

    public static function main() : Int {
#if cpp
    return sysMain();
#else
    return randomTests();
#end
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


    public static function jsonify(t: Table) : Dynamic {
        var workbook : Hash<Dynamic> = new Hash<Dynamic>();
        var sheet : Array<Array<Dynamic>> = new Array<Array<Dynamic>>();
        var w : Int = t.width;
        var h : Int = t.height;
        var txt : String = "";
        for (y in 0...h) {
            var row : Array<Dynamic> = new Array<Dynamic>();
            for (x in 0...w) {
                var v = t.getCell(x,y);
                if (v!=null) {
                    row.push(v.toString());
                } else {
                    row.push(null);
                }
            }
            sheet.push(row);
        }
        workbook.set("sheet",sheet);
        return workbook;
    }
}
