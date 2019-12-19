// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class SqlTable implements Table implements Meta implements RowStream {
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
        if (helper==null) this.helper = db.getHelper();
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
        } else if (y==0) {
            y = -1;
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

    public var height(get,never) : Int;
    public var width(get,never) : Int;

    public function get_width() : Int {
        getColumns();
        return columns.length;
    }

    public function get_height() : Int {
        if (h>=0) return h;
        return -1;
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
        return this;
    }

    public function alterColumns(columns : Array<ColumnChange>) : Bool {
        // pass the request on, too db-specific to do anything useful here
        var result = helper.alterColumns(db,name,columns);
        this.columns = null;
        return result;
    }

    public function changeRow(rc: RowChange) : Bool {
        if (helper==null) {
            trace("No sql helper");
            return false;
        }
        if (rc.action == "+++") {
            return helper.insert(db,name,rc.val);
        } else if (rc.action == "---") {
            return helper.delete(db,name,rc.cond);
        } else if (rc.action == "->") {
            return helper.update(db,name,rc.cond,rc.val);
        }
        return false;
    }

    public function asTable() : Table {
        var pct = 3;
        getColumns();
        var w = columnNames.length;
        var mt = new SimpleTable(w+1,pct);
        mt.setCell(0,0,"@");
        mt.setCell(0,1,"type");
        mt.setCell(0,2,"key");
        for (x in 0...w) {
            var i = x+1;
            mt.setCell(i,0,columnNames[x]);
            mt.setCell(i,1,columns[x].type_value);
            mt.setCell(i,2,columns[x].primary ? "primary" : "");
        }
        return mt;
    }

    public function useForColumnChanges() : Bool {
        return true;
    }

    public function useForRowChanges() : Bool {
        return true;
    }

    public function cloneMeta(table: Table = null) : Meta {
        return null;
    }

    public function applyFlags(flags: CompareFlags) : Bool {
        return false;
    }

    public function getDatabase() : SqlDatabase {
        return db;
    }

    public function getRowStream() : RowStream {
        getColumns();
        db.begin("SELECT * FROM " + getQuotedTableName() + " ORDER BY ?",[db.rowid()],columnNames);
        return this;
    }

    public function isNested() : Bool {
        return false;
    }

    public function isSql() : Bool {
        return true;
    }

    public function fetchRow() : Map<String, Dynamic> {
        if (db.read()) {
            var row = new Map<String,Dynamic>();
            for (i in 0...columnNames.length) {
                row[columnNames[i]] = db.get(i);
            }
            return row;
        } 
        db.end();
        return null;
    }

    public function fetchColumns() : Array<String> {
        getColumns();
        return columnNames;
    }

    public function getName() : String {
        return name.toString();
    }
}


