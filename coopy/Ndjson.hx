// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Read and write NDJSON format. You don't need to use this to use daff!
 * Feel free to use your own.
 *
 */
@:expose
class Ndjson {
    private var tab : Table;
    private var view : View;
    private var columns : Map<String,Int>;
    private var header_row : Int;
    private var have_rc : Bool;

    public function new(tab: Table) {
        this.tab = tab;
        view = tab.getCellView();
        header_row = 0;
        have_rc = false;
    }

    private function hashifyRow(oview: View, r: Int) : Dynamic {
        var row = oview.makeHash();
        for (c in 0...tab.width) {
            var key0 : Dynamic = tab.getCell(c,header_row);
            if (view.isHash(key0)) {
                if (view.hashExists(key0,"after")) {
                    key0 = view.hashGet(key0,"after");
                } else {
                    key0 = view.hashGet(key0,"before");
                }
            }
            var key = view.toString(key0);
            //var key = view.toString(tab.getCell(c,header_row));
            //if (c==0&&have_rc) key = "@:@";
            //var cell = DiffRender.renderCell(tab,view,c,r);
            var raw = tab.getCell(c,r);
            oview.hashSet(row,key,raw);
        }
        return row;
    }

    /**
     *
     * Convert a table row to a string in NDJSON format.
     *
     * @param t the table to render
     * @param r the row to render
     * @return the row as a string in NDJSON format
     *
     */
    public function renderRow(r: Int) : String {
        var row = new Map<String,Dynamic>();
        for (c in 0...tab.width) {
            var key0 : Dynamic = tab.getCell(c,header_row);
            if (view.isHash(key0)) {
                if (view.hashExists(key0,"after")) {
                    key0 = view.hashGet(key0,"after");
                } else {
                    key0 = view.hashGet(key0,"before");
                }
            }
            var key = view.toString(key0);
            var raw = tab.getCell(c,r);
            row.set(key,raw);
        }
        return haxe.Json.stringify(row);
    }

    public function render() : String {
        var txt = "";
        var offset = 0;
        if (tab.height==0) return txt;
        if (tab.width==0) return txt;
        if (tab.getCell(0,0) == "@:@") {
            offset = 1;
            have_rc = true;
            if (tab.height==1) return txt;
        }
        if (tab.getCell(0,offset) == "!") {
            offset++;
        }
        header_row = offset;
        for (r in (header_row)...tab.height) {
            txt += renderRow(r);
            txt += "\n";
        }
        return txt;
    }

    public function renderToTable(output: Table) : Bool {
        if (!output.isResizable()) return false;
        output.resize(0,0);
        output.clear();
        var offset = 0;
        if (tab.height==0) return true;
        if (tab.width==0) return true;
        if (tab.getCell(0,0) == "@:@") {
            offset = 1;
            have_rc = true;
            if (tab.height==1) return true;
        }
        if (tab.getCell(0,offset) == "!") {
            offset++;
        }
        output.resize(tab.height-header_row-1,1);
        header_row = offset;
        var oview = output.getCellView();
        for (r in (header_row)...tab.height) {
            output.setCell(r-header_row,0,hashifyRow(oview,r));
        }
        return true;
    }

    private function addRow(r: Int, txt: String) {
        var json = haxe.Json.parse(txt);
        if (columns==null) columns = new Map<String,Int>();
        var w : Int = tab.width;
        var h : Int = tab.height;
        var resize : Bool = false;
        for (name in Reflect.fields(json)) {
            if (!columns.exists(name)) {
                columns.set(name,w);
                w++;
                resize = true;
            }
        }
        if (r>=h) {
            h = r+1;
            resize = true;
        }
        if (resize) {
            tab.resize(w,h);
        }
        for (name in Reflect.fields(json)) {
            var v = Reflect.field(json,name);
            var c = columns.get(name);
            tab.setCell(c,r,v);
        }
    }

    private function addHeaderRow(r: Int) {
        var names = columns.keys();
        for (n in names) {
            tab.setCell(columns.get(n),r,view.toDatum(n));
        }
    }

    public function parse(txt: String) {
        columns = null;
        var rows = txt.split("\n");
        var h = rows.length;
        if (h==0) {
            tab.clear();
            return;
        }
        if (rows[h-1] == "") {
            h--;
        }
        for (i in 0...h) {
            var at = h-i-1;
            addRow(at+1,rows[at]);
        }
        addHeaderRow(0);
    }
}
