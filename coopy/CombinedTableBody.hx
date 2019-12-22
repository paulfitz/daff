// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Body of a table that has embedded meta-data.
 *
 */
class CombinedTableBody implements Table {
    private var parent : CombinedTable;
    private var dx : Int;
    private var dy : Int;
    private var all : Table;
    private var meta : Table;

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
        all = parent.all();
    }

    public function getTable() : Table {
        return this;
    }

    public var height(get,never) : Int;
    public var width(get,never) : Int;

    public function get_width() : Int {
        return all.width-1;
    }

    public function get_height() : Int {
        return all.height-dy+1;
    }

    public function getCell(x: Int, y: Int) : Dynamic {
        if (y==0) {
            if (meta==null) {
                meta = parent.getMeta().asTable();
            }
            return meta.getCell(x+dx,0);
        }
        return all.getCell(x+dx,y+dy-1);
    }

    public function setCell(x: Int, y: Int, c: Dynamic) : Void {
        if (y==0) {
            all.setCell(x+dx,0,c);
            return;
        }
        all.setCell(x+dx,y+dy-1,c);
    }

    public function toString() : String {
        return SimpleTable.tableToString(this);
    }
    
    public function getCellView() : View {
        return all.getCellView();
    }

    public function isResizable() : Bool {
        return all.isResizable();
    }

    public function resize(w: Int, h: Int) : Bool {
        return all.resize(w+1,h+dy);
    }

    public function clear() : Void {
        all.clear();
        dx = 0;
        dy = 0;
    }

    public function insertOrDeleteRows(fate: Array<Int>, hfate: Int) : Bool {
        var fate2 = new Array<Int>();
        for (y in 0...dy) {
            fate2.push(y);
        }
        var hdr = true;
        for (f in fate) {
            if (hdr) {
                hdr = false;
                continue;
            }
            fate2.push((f>=0)?(f+dy-1):f);
        }
        return all.insertOrDeleteRows(fate2,hfate+dy-1);
    }

    public function insertOrDeleteColumns(fate: Array<Int>, wfate: Int) : Bool {
        var fate2 = new Array<Int>();
        for (x in 0...(dx+1)) {
            fate2.push(x);
        }
        for (f in fate) {
            fate2.push((f>=0)?(f+dx+1):f);
        }
        return all.insertOrDeleteColumns(fate2,wfate+dx);
    }

    public function trimBlank() : Bool {
        return all.trimBlank();
    }

    public function getData() : Dynamic {
        return null;
    }

    public function clone() : Table {
        return new CombinedTable(all.clone());
    }

    public function create() : Table {
        return new CombinedTable(all.create());
    }

    public function getMeta() : Meta {
        return parent.getMeta();
    }
}
