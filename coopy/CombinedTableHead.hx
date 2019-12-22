// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Head of a table that has embedded meta-data.
 *
 */
class CombinedTableHead implements Table {
    private var parent : CombinedTable;
    private var dx : Int;
    private var dy : Int;
    private var all : Table;

    /**
     *
     * Constructor.
     * @param parent the composite table
     *
     */
    public function new(parent: CombinedTable, dx: Int, dy: Int) : Void {
        this.parent = parent;
        this.dx = dx;
        this.dy = dy;
        this.all = parent.all();
    }

    public function getTable() : Table {
        return this;
    }

    public var height(get,never) : Int;
    public var width(get,never) : Int;

    public function get_width() : Int {
        return all.width;
    }

    public function get_height() : Int {
        return dy;
    }

    public function getCell(x: Int, y: Int) : Dynamic {
        if (x==0) {
            var v = getCellView();
            var txt = v.toString(all.getCell(x,y));
            if (txt.charAt(0)=='@') return txt.substr(1,txt.length);
        }
        return all.getCell(x,y);
    }

    public function setCell(x: Int, y: Int, c: Dynamic) : Void {
        all.setCell(x,y,c);
    }

    public function toString() : String {
        return SimpleTable.tableToString(this);
    }
    
    public function getCellView() : View {
        return all.getCellView();
    }

    public function isResizable() : Bool {
        return false;
    }

    public function resize(w: Int, h: Int) : Bool {
        return false;
    }

    public function clear() : Void {
    }

    public function insertOrDeleteRows(fate: Array<Int>, hfate: Int) : Bool {
        return false;
    }

    public function insertOrDeleteColumns(fate: Array<Int>, wfate: Int) : Bool {
        return all.insertOrDeleteColumns(fate,wfate);
    }

    public function trimBlank() : Bool {
        return false;
    }

    public function getData() : Dynamic {
        return null;
    }

    public function clone() : Table {
        return null;
    }

    public function create() : Table {
        return null;
    }

    public function getMeta() : Meta {
        return null;
    }
}
