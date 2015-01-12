// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

class SqliteHelper implements SqlHelper {
    public function new() {
    }
    
    public function getTableNames(db: SqlDatabase) : Array<String> {
        var q = "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name";
        if (!db.begin(q,null,["name"])) return null;
        var names = new Array<String>();
        while (db.read()) {
            names.push(db.get(0));
        }
        db.end();
        return names;
    }
    
    public function countRows(db: SqlDatabase, name: SqlTableName) : Int {
        var q = "SELECT COUNT(*) AS ct FROM " + db.getQuotedTableName(name);
        if (!db.begin(q,null,["ct"])) return -1;
        var ct : Int = -1;
        while (db.read()) {
            ct = db.get(0);
        }
        db.end();
        return ct;
    }

    public function getRowIDs(db: SqlDatabase, name: SqlTableName) : Array<Int> {
        var result = new Array<Int>();
        var q = "SELECT ROWID AS r FROM " + db.getQuotedTableName(name) + " ORDER BY ROWID";
        if (!db.begin(q,null,["r"])) return null;
        while (db.read()) {
            var c : Int = cast db.get(0);
            result.push(c);
        }
        db.end();
        
        return result;
    }

}
