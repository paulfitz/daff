// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class Coopy {
    private var format_preference : String;

    public function new() : Void {
    }

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

    static private  function randomTests() : Int {
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
        var hp : HighlightPatch = new HighlightPatch(null,null);
        var csv : Csv = new Csv();

        return 0;
    }

#if cpp

    private function saveTable(name: String, t: Table) : Bool {
        var txt : String = "";
        if (format_preference!="json") {
            var csv : Csv = new Csv();
            txt = csv.renderTable(t);
        } else {
            txt = haxe.Json.stringify(jsonify(t));
        }
        if (name!="-") {
            sys.io.File.saveContent(name,txt);
        } else {
            Sys.stdout().writeString(txt);
        }
        return true;
    }

    private static function cellFor(x: Dynamic) : Datum {
        if (x==null) return null;
        return new SimpleCell(x);
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
                        output.setCell(j,i,cellFor(val));
                    }
                } else {
                    for (j in 0...columns.length) {
                        var val = Reflect.field(row,columns[j]);
                        output.setCell(j,i,cellFor(val));
                    }
                }
            }
        }
        if (output!=null) output.trimBlank();
        return output;
    }

    private function loadTable(name: String) : Table {
        var txt : String = sys.io.File.getContent(name);
        try {
            var json = haxe.Json.parse(txt);
            format_preference = "json";
            return jsonToTable(json);
        } catch (e: Dynamic) {
            var csv : Csv = new Csv();
            format_preference = "csv";
            var data : Array<Array<String>> = csv.parseTable(txt);
            var h : Int = data.length;
            var w : Int = 0;
            if (h>0) w = data[0].length;
            var output = new SimpleTable(w,h);
            for (i in 0...h) {
                for (j in 0...w) {
                    var val : String = data[i][j];
                    output.setCell(j,i,cellFor(val));
                }
            }
            if (output!=null) output.trimBlank();
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
        var cmd : String = args[0];
        
        if (args.length < 2 || (!Lambda.has(["diff","patch","trim"],cmd))) {
            Sys.stderr().writeString("Howdy.  coopyhx doesn't have much of a command line interface.\n");
            Sys.stderr().writeString("You may want the coopy toolbox https://github.com/paulfitz/coopy\n");
            Sys.stderr().writeString("If you do want coopyhx - call as:\n");
            Sys.stderr().writeString("  coopyhx diff [--output OUTPUT.csv] a.csv b.csv\n");
            Sys.stderr().writeString("  coopyhx diff [--output OUTPUT.csv] parent.csv a.csv b.csv\n");
            Sys.stderr().writeString("  coopyhx diff [--output OUTPUT.jsonbook] a.jsonbook b.jsonbook\n");
            Sys.stderr().writeString("  coopyhx patch [--output OUTPUT.csv] source.csv patch.csv\n");
            Sys.stderr().writeString("  coopyhx trim [--output OUTPUT.csv] source.csv\n");
            return 1;
        }
        if (output == null) {
            output = "-";
        }
        var cmd : String = args[0];
        var tool : Coopy = new Coopy();
        var parent = null;
        var offset : Int = 0;
        if (args.length>3) {
            parent = tool.loadTable(args[1]);
            offset++;
        }
        var a = tool.loadTable(args[1+offset]);
        var b = null;
        if (args.length>2) {
            b = tool.loadTable(args[2+offset]);
        }
        if (cmd=="diff") {
            var ct : CompareTable = compareTables3(parent,a,b);
            var align : Alignment = ct.align();
            var flags : CompareFlags = new CompareFlags();
            flags.always_show_header = true;
            var td : TableDiff = new TableDiff(align,flags);
            var o = new SimpleTable(0,0);
            td.hilite(o);
            tool.saveTable(output,o);
        } else if (cmd=="patch") {
            var patcher : HighlightPatch = new HighlightPatch(a,b);
            patcher.apply();
            tool.saveTable(output,a);
        } else if (cmd=="trim") {
            tool.saveTable(output,a);
        }
        return 0;
    }
#end

    public static function main() : Int {
#if cpp
    return sysMain();
#else
    // do nothing
    return 0;
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
        var workbook : Map<String,Dynamic> = new Map<String,Dynamic>();
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
