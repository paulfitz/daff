// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * View a table on its side, with rows and columns switched.
 *
 */
@:expose
class FlipTable implements Table {
    private var t : Table;

    /**
     *
     * Constructor.
     * @param t the table to flip
     *
     */
    public function new(t: Table) : Void {
        this.t = t;
    }

    public function getTable() : Table {
        return this;
    }

    public var height(get_height,never) : Int;
    public var width(get_width,never) : Int;

    public function get_width() : Int {
        return t.height;
    }

    public function get_height() : Int {
        return t.width;
    }

    public function getCell(x: Int, y: Int) : Dynamic {
        return t.getCell(y,x);
    }

    public function setCell(x: Int, y: Int, c: Dynamic) : Void {
        t.setCell(y,x,c);
    }

    public function toString() : String {
        return SimpleTable.tableToString(this);
    }
    
    public function getCellView() : View {
        return t.getCellView();
    }

    public function isResizable() : Bool {
        return t.isResizable();
    }

    public function resize(w: Int, h: Int) : Bool {
        return t.resize(h,w);
    }

    public function clear() : Void {
        t.clear();
    }

    public function insertOrDeleteRows(fate: Array<Int>, hfate: Int) : Bool {
        return t.insertOrDeleteColumns(fate,hfate);
    }

    public function insertOrDeleteColumns(fate: Array<Int>, wfate: Int) : Bool {
        return t.insertOrDeleteRows(fate,hfate);
    }

    public function trimBlank() : Bool {
        return t.trimBlank();
    }

    public function getData() : Dynamic {
        return null;
    }

    public function clone() : Table {
        return new FlipTable(t.clone());
    }

    public function getMetaTable() : Table {
        return new FlipTable(t.getMetaTable());
    }
}
