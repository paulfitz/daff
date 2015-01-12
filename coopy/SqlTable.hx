// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class SqlTable implements Table {
    private var db: SqlDatabase;
    private var columns: Array<SqlColumn>;
    private var name: SqlTableName;
    private var quotedTableName: String;
    private var cache: Map<Int,Map<Int,Dynamic>>;
    private var columnNames: Array<String>;
    private var h: Int;
    private var helper: SqlHelper;
    private var id2rid: Array<Int>;

    private function getColumns() : Void {
        if (columns!=null) return;
        if (db==null) return;
        columns = db.getColumns(name);
        columnNames = new Array<String>();
        for (col in columns) {
            columnNames.push(col.getName());
        }
    }

    public function new(db: SqlDatabase, name: SqlTableName, helper: SqlHelper = null) {
        this.db = db;
        this.name = name;
        this.helper = helper;
        cache = new Map<Int,Map<Int,Dynamic>>();
        h = -1;
        id2rid = null;
        getColumns();
    }

    public function getPrimaryKey() : Array<String> {
        getColumns();
        var result = new Array<String>();
        for (col in columns) {
            if (!col.isPrimaryKey()) continue;
            result.push(col.getName());
        }
        return result;
    }

    public function getAllButPrimaryKey() : Array<String> {
        getColumns();
        var result = new Array<String>();
        for (col in columns) {
            if (col.isPrimaryKey()) continue;
            result.push(col.getName());
        }
        return result;
    }

    public function getColumnNames() : Array<String> {
        getColumns();
        return columnNames;
    }

    public function getQuotedTableName() : String {
        if (quotedTableName!=null) return quotedTableName;
        quotedTableName = db.getQuotedTableName(name);
        return quotedTableName;
    }

    public function getQuotedColumnName(name : String) : String {
        return db.getQuotedColumnName(name);
    }

    public function getCell(x: Int, y: Int) : Dynamic {
        if (h>=0) {
            y = y-1;
            if (y>=0) {
                y = id2rid[y];
            }
        }
        if (y<0) {
            getColumns();
            return columns[x].name;
        }
        var row = cache[y];
        if (row==null) {
            row = new Map<Int,Dynamic>();
            getColumns();
            db.beginRow(name,y,columnNames);
            while (db.read()) {
                for (i in 0...width) {
                    row[i] = db.get(i);
                }
            }
            db.end();
            cache[y] = row;
        }
        return cache[y][x];
    }

    public function setCellCache(x: Int, y: Int, c: Dynamic) : Void {
        var row = cache[y];
        if (row==null) {
            row = new Map<Int,Dynamic>();
            getColumns();
            cache[y] = row;
        }
        row[x] = c;
    }

    public function setCell(x: Int, y: Int, c : Dynamic) : Void {
        trace("SqlTable cannot set cells yet");
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

    public var height(get_height,never) : Int;
    public var width(get_width,never) : Int;

    public function get_width() : Int {
        getColumns();
        return columns.length;
    }

    public function get_height() : Int {
        if (h>=0) return h;
        if (helper==null) return -1;
        id2rid = helper.getRowIDs(db,name);
        h = id2rid.length+1;
        return h;
    }

    public function getData() : Dynamic {
        return null;
    }

    public function clone() : Table {
        return null;
    }
}


