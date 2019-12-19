// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * A basic table implementation. Each supported language should
 * have an optimized native implementation that you can use instead.
 * See the `Table` interface for documentation.
 *
 */
@:expose
class SimpleTable implements Table {
    private var data : Map<Int,Dynamic>;
    private var w : Int;
    private var h : Int;
    private var meta : Meta;

    /**
     *
     * Constructor.
     * @param w the desired width of the table
     * @param h the desired height of the table
     *
     */
    public function new(w: Int, h: Int) : Void {
        data = new Map<Int,Dynamic>();
        this.w = w;
        this.h = h;
        this.meta = null;
    }

    public function getTable() : Table {
        return this;
    }

    public var height(get,never) : Int;
    public var width(get,never) : Int;

    public function get_width() : Int {
        return w;
    }

    public function get_height() : Int {
        return h;
    }

    public function getCell(x: Int, y: Int) : Dynamic {
        return data.get(x+y*w);
    }

    public function setCell(x: Int, y: Int, c: Dynamic) : Void {
        data.set(x+y*w,c);
    }

    public function toString() : String {
        return tableToString(this);
    }
    
    /**
     *
     * Render the table as a string
     *
     * @param tab the table
     * @return a text version of the table
     *
     */
    public static function tableToString(tab : Table) : String {
        var meta = tab.getMeta();
        if (meta!=null) {
            var stream = meta.getRowStream();
            if (stream!=null) {
                var x : String = "";
                var cols = stream.fetchColumns();
                for (i in 0...cols.length) {
                    if (i>0) x += ",";
                    x += cols[i];
                }
                x += "\n";
                var row : Map<String,Dynamic> = stream.fetchRow();
                while(row!=null) {
                    for (i in 0...cols.length) {
                        if (i>0) x += ",";
                        x += row[cols[i]];
                    }
                    x += "\n";
                    row = stream.fetchRow();
                }
                return x;
            }
        }
        var x : String = "";
        for (i in 0...tab.height) {
            for (j in 0...tab.width) {
                if (j>0) x += ",";
                x += tab.getCell(j,i);
            }
            x += "\n";
        }
        return x;
    }

    /**
     *
     * Compare the content of two tables.
     *
     * @param tab1 the first table
     * @param tab2 the second table
     * @return true if the tables are identical
     *
     */
    public static function tableIsSimilar(tab1 : Table, tab2 : Table) : Bool {
        if (tab1.height==-1 || tab2.height==-1) {
            // At least one table is streaming.
            var txt1 = tableToString(tab1);
            var txt2 = tableToString(tab2);
            return txt1 == txt2;
        }
        if (tab1.width!=tab2.width) return false;
        if (tab1.height!=tab2.height) return false;
        var v = tab1.getCellView();
        for (i in 0...tab1.height) {
            for (j in 0...tab1.width) {
                if (!v.equals(tab1.getCell(j,i),tab2.getCell(j,i))) return false;
            }
        }
        return true;
    }
    
    public function getCellView() : View {
        return new SimpleView();
    }

    public function isResizable() : Bool {
        return true;
    }

    public function resize(w: Int, h: Int) : Bool {
        this.w = w;
        this.h = h;
        return true;
    }

    public function clear() : Void {
        data = new Map<Int,Dynamic>();
    }

    public function insertOrDeleteRows(fate: Array<Int>, hfate: Int) : Bool {
        var data2 : Map<Int,Dynamic> = new Map<Int,Dynamic>();
        for (i in 0...fate.length) {
            var j : Int = fate[i];
            if (j!=-1) {
                for (c in 0...w) {
                    var idx : Int = i*w+c;
                    if (data.exists(idx)) {
                        data2.set(j*w+c,data.get(idx));
                    }
                }
            }
        }
        h = hfate;
        data = data2;
        return true;
    }

    public function insertOrDeleteColumns(fate: Array<Int>, wfate: Int) : Bool {
        var data2 : Map<Int,Dynamic> = new Map<Int,Dynamic>();
        for (i in 0...fate.length) {
            var j : Int = fate[i];
            if (j!=-1) {
                for (r in 0...h) {
                    var idx : Int = r*w+i;
                    if (data.exists(idx)) {
                        data2.set(r*wfate+j,data.get(idx));
                    }
                }
            }
        }
        w = wfate;
        data = data2;
        return true;
    }

    public function trimBlank() : Bool {
        if (h==0) return true;
        var h_test : Int = h;
        if (h_test>=3) h_test = 3;
        var view : View = getCellView();
        var space : Dynamic = view.toDatum("");
        var more : Bool = true;
        while (more) {
            for (i in 0...width) {
                var c : Dynamic = getCell(i,h-1);
                if (!(view.equals(c,space)||c==null)) {
                    more = false;
                    break;
                }
            }
            if (more) h--;
        }
        more = true;
        var nw : Int = w;
        while (more) {
            if (w==0) break;
            for (i in 0...h_test) {
                var c : Dynamic = getCell(nw-1,i);
                if (!(view.equals(c,space)||c==null)) {
                    more = false;
                    break;
                }
            }
            if (more) nw--;
        }
        if (nw==w) return true;
        var data2 : Map<Int,Dynamic> = new Map<Int,Dynamic>();
        for (i in 0...nw) {
            for (r in 0...h) {
                var idx : Int = r*w+i;
                if (data.exists(idx)) {
                    data2.set(r*nw+i,data.get(idx));
                }
            }
        }
        w = nw;
        data = data2;
        return true;
    }

    public function getData() : Dynamic {
        return null;
    }

    public function clone() : Table {
        var result = new SimpleTable(width,height);
        for (i in 0...height) {
            for (j in 0...width) {
                result.setCell(j,i,getCell(j,i));
            }
        }
        if (meta!=null) {
            result.meta = meta.cloneMeta(result);
        }
        return result;
    }

    public function create() : Table {
        return new SimpleTable(width,height);
    }

    public function setMeta(meta: Meta) {
        this.meta = meta;
    }

    public function getMeta() : Meta {
        return meta;
    }
}
