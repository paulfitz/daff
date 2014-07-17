// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class TerminalDiffRender {
    public function new() {
    }

    public function render(t: Table) : String {
        var csv  = new Csv();
        var result: String = "";
        var w : Int = t.width;
        var h : Int = t.height;
        var txt : String = "";
        var v : View = t.getCellView();
        var tt : TableText = new TableText(t);

        var codes = new Map<String,String>();
        codes.set("header","\x1b[0;1m");
        codes.set("add","\x1b[32;1m");
        codes.set("conflict","\x1b[33;1m");
        codes.set("modify","\x1b[34;1m");
        codes.set("remove","\x1b[31;1m");
        codes.set("done","\x1b[0m");
        for (y in 0...h) {
            for (x in 0...w) {
                if (x>0) {
                    txt += ",";
                }
                var val : String = tt.getCellText(x,y);
                if (val==null) val = "";
                var cell = DiffRender.renderCell(tt,x,y);
                var code = null;
                if (cell.category!=null) {
                    code = codes[cell.category];
                }
                if (code!=null) {
                    if (cell.rvalue!=null) {
                        val = codes["remove"] + cell.lvalue + codes["modify"] + cell.separator + codes["add"] + cell.rvalue + codes["done"];
                        if (cell.pvalue!=null) {
                            val = codes["conflict"] + cell.pvalue + codes["modify"] + cell.separator + val;
                        }
                    } else {
                        val = code + val + codes["done"];
                    }
                }
                txt += csv.renderCell(v,val);
            }
            txt += "\r\n";
        }
        return txt;
    }
}
