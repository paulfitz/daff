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

    public function new(tab: Table) {
        this.tab = tab;
        view = tab.getCellView();
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
            row.set(view.toString(tab.getCell(c,0)),tab.getCell(c,r));
        }
        return haxe.Json.stringify(row);
    }

    public function render() : String {
        var txt = "";
        for (r in 1...tab.height) {
            txt += renderRow(r);
            txt += "\n";
        }
        return txt;
    }

    public function addRow(r: Int, txt: String) {
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

    public function addHeaderRow(r: Int) {
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
