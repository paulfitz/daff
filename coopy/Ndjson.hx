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

    /**
     *
     * Constructor.
     *
     * @param tab a table to read or write.
     *
     */
    public function new(tab: Table) {
        this.tab = tab;
        view = tab.getCellView();
        header_row = 0;
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
            var key = view.toString(tab.getCell(c,header_row));
            if (c==0&&header_row==1) key = "@:@";
            row.set(key,tab.getCell(c,r));
        }
        return haxe.Json.stringify(row);
    }

    /**
     *
     * @return an entire table converted into a single string in NDJSON format.
     *
     */
    public function render() : String {
        var txt = "";
        var offset = 0;
        if (tab.height==0) return txt;
        if (tab.width==0) return txt;
        if (tab.getCell(0,0) == "@:@") {
            offset = 1;
        }
        header_row = offset;
        for (r in (header_row+1)...tab.height) {
            txt += renderRow(r);
            txt += "\n";
        }
        return txt;
    }

    /**
     *
     * Parse a string expressing a single row of the table in NDJSON format,
     * and insert it at the specified location.  The table is resized if 
     * necessary.  Row number zero should be reserved for a header, with actual
     * data starting at row 1.
     *
     * @param r the target row number - the table will be resized if necessary.
     * @param txt the row expressed as a string in NDJSON format.
     *
     */
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

    /**
     *
     * Insert column names in the specified row.
     *
     * @param r the header row number.  This would usually be zero.
     *
     */
    public function addHeaderRow(r: Int) {
        var names = columns.keys();
        for (n in names) {
            tab.setCell(columns.get(n),r,view.toDatum(n));
        }
    }

    /**
     *
     * Convert a string containing rows in NDJSON format into a table.
     *
     * @param txt the table expressed as a string in NDJSON format
     *
     */
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
