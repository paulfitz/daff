// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

class JsonTable implements Table implements Meta {
    private var w : Int;
    private var h : Int;
    private var columns : Array<String>;
    private var rows : Array<Map<String,Dynamic>>;
    private var data : Dynamic;
    private var idx2col : Map<Int,String>;
    private var name : String;

    public function new(data: Dynamic, name: String) : Void {
        this.data = data;
        this.columns = cast Reflect.field(data, "columns");
        this.rows = cast Reflect.field(data, "rows");
        this.w = this.columns.length;
        this.h = this.rows.length;
        idx2col = new Map<Int,String>();
        for (idx in 0...this.columns.length) {
            idx2col[idx] = this.columns[idx];
        }
        this.name = name;
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
        return h+1;
    }

    public function getCell(x: Int, y: Int) : Dynamic {
        if (y==0) {
            return idx2col[x];
        }
        return Reflect.field(rows[y-1], idx2col[x]);
    }

    public function setCell(x: Int, y: Int, c: Dynamic) : Void {
        trace("JsonTable is read-only");
    }

    public function toString() : String {
        return "";
    }

    public function getCellView() : View {
        return new SimpleView();
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
        return false;
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

    public function setMeta(meta: Meta) {
    }

    public function getMeta() : Meta {
        return this;
    }

    public function create() : Table {
        return null;
    }

    public function alterColumns(columns : Array<ColumnChange>) : Bool {
        return false;
    }

    public function changeRow(rc: RowChange) : Bool {
        return false;
    }

    public function applyFlags(flags: CompareFlags) : Bool {
        return false;
    }

    public function asTable() : Table {
        return null;
    }

    public function cloneMeta(table: Table = null) : Meta {
        return null;
    }

    public function useForColumnChanges() : Bool {
        return false;
    }

    public function useForRowChanges() : Bool {
        return false;
    }

    public function getRowStream() : RowStream {
        return null;
    }

    public function isNested() : Bool {
        return false;
    }

    public function isSql() : Bool {
        return false;
    }

    public function getName() : String {
        return name;
    }
}
