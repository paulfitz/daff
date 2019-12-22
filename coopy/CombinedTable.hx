// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Take a table that may include meta-data and spit it into a regular table and a
 * meta-data table.
 *
 */
@:expose
class CombinedTable implements Table {
    private var t : Table;
    private var body : CombinedTableBody;
    private var head : CombinedTableHead;
    private var dx : Int;
    private var dy : Int;
    private var core : Table;
    private var meta : Meta;

    public function all() {
        return t;
    }

    /**
     *
     * Constructor.
     * @param t the table to wrap
     *
     */
    public function new(t: Table) : Void {
        this.t = t;
        dx = 0;
        dy = 0;
        core = t;
        head = null;
        if (t.width<1 || t.height<1) return;
        var v = t.getCellView();
        if (v.toString(t.getCell(0,0))!="@@") return;
        dx = 1;
        dy = 0;
        for (y in 0...t.height) {
            var txt = v.toString(t.getCell(0,y));
            if (txt==null || txt=="" || txt=="null") {
                break;
            }
            dy++;
        }
        this.head = new CombinedTableHead(this,dx,dy);
        this.body = new CombinedTableBody(this,dx,dy);
        core = this.body;
        meta = new SimpleMeta(head);
    }

    public function getTable() : Table {
        return this;
    }

    public var height(get,never) : Int;
    public var width(get,never) : Int;

    public function get_width() : Int {
        return core.width;
    }

    public function get_height() : Int {
        return core.height;
    }

    public function getCell(x: Int, y: Int) : Dynamic {
        return core.getCell(x,y);
    }

    public function setCell(x: Int, y: Int, c: Dynamic) : Void {
        core.setCell(x,y,c);
    }

    public function toString() : String {
        return SimpleTable.tableToString(this);
    }
    
    public function getCellView() : View {
        return t.getCellView();
    }

    public function isResizable() : Bool {
        return core.isResizable();
    }

    public function resize(w: Int, h: Int) : Bool {
        return core.resize(h,w);
    }

    public function clear() : Void {
        core.clear();
    }

    public function insertOrDeleteRows(fate: Array<Int>, hfate: Int) : Bool {
        return core.insertOrDeleteRows(fate,hfate);
    }

    public function insertOrDeleteColumns(fate: Array<Int>, wfate: Int) : Bool {
        return core.insertOrDeleteColumns(fate,wfate);
    }

    public function trimBlank() : Bool {
        return core.trimBlank();
    }

    public function getData() : Dynamic {
        return null;
    }

    public function clone() : Table {
        return core.clone();
    }

    public function create() : Table {
        return t.create();
    }

    public function getMeta() : Meta {
        return meta;
    }
}
