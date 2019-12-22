// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class SqlTables implements Table {
    private var db: SqlDatabase;
    private var t: Table;
    private var flags: CompareFlags;

    public function new(db: SqlDatabase, flags: CompareFlags, role: String) {
        this.db = db;
        var helper = this.db.getHelper();
        var names = helper.getTableNames(db);
        var allowed : Map<String,String> = null;
        var count : Int = names.length;
        if (flags.tables!=null) {
            allowed = new Map<String,String>();
            for (name in flags.tables) {
                allowed.set(flags.getNameByRole(name, role),flags.getCanonicalName(name));
            }
            count = 0;
            for (name in names) {
                if (allowed.exists(name)) {
                    count++;
                }
            }
        }
        t = new SimpleTable(2,count+1);
        t.setCell(0,0,"name");
        t.setCell(1,0,"table");
        var v = t.getCellView();
        var at = 1;
        for (name in names) {
            var cname = name;
            if (allowed!=null) {
                if (!allowed.exists(name)) continue;
                cname = allowed.get(name);
            }
            t.setCell(0,at,cname);
            t.setCell(1,at,v.wrapTable(new SqlTable(db, new SqlTableName(name))));
            at++;
        }
    }

    public var height(get,never) : Int;
    public var width(get,never) : Int;

    public function getCell(x: Int, y: Int) : Dynamic {
        return t.getCell(x,y);
    }

    public function setCell(x: Int, y: Int, c : Dynamic) : Void {
    }

    public function getCellView() : View {
        return t.getCellView();
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

    public function get_width() : Int {
        return t.width;
    }

    public function get_height() : Int {
        return t.height;
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
        return new SimpleMeta(this,true,true);
    }
}
