// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
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

    public function update(db: SqlDatabase, name: SqlTableName, 
                           conds: Map<String, Dynamic>,
                           vals: Map<String, Dynamic>) : Bool {
        var q = "UPDATE " + db.getQuotedTableName(name) + " SET ";
        var lst = new Array<Dynamic>();
        for (k in vals.keys()) {
            if (lst.length>0) {
                q += ", ";
            }
            q += db.getQuotedColumnName(k);
            q += " = ?";
            lst.push(vals.get(k));
        }
        var val_len = lst.length;
        q += " WHERE ";
        for (k in conds.keys()) {
            if (lst.length>val_len) {
                q += " and ";
            }
            q += db.getQuotedColumnName(k);
            q += " = ?";
            lst.push(conds.get(k));
        }
        //trace(q + " // " + lst);
        if (!db.begin(q,lst,[])) {
            trace("Problem with database update");
            return false;
        }
        db.end();
        return true;
    }

    public function delete(db: SqlDatabase, name: SqlTableName, conds: Map<String, Dynamic>) : Bool {
        var q = "DELETE FROM " + db.getQuotedTableName(name) + " WHERE ";
        var lst = new Array<Dynamic>();
        for (k in conds.keys()) {
            if (lst.length>0) {
                q += " and ";
            }
            q += db.getQuotedColumnName(k);
            q += " = ?";
            lst.push(conds.get(k));
        }
        //trace(q);
        if (!db.begin(q,lst,[])) {
            trace("Problem with database delete");
            return false;
        }
        db.end();
        return true;
    }

    public function insert(db: SqlDatabase, name: SqlTableName, vals: Map<String, Dynamic>) : Bool {
        var q = "INSERT INTO " + db.getQuotedTableName(name) + " (";
        var lst = new Array<Dynamic>();
        for (k in vals.keys()) {
            if (lst.length>0) {
                q += ",";
            }
            q += db.getQuotedColumnName(k);
            lst.push(vals.get(k));
        }
        q += ") VALUES(";
        var need_comma = false;
        for (k in vals.keys()) {
            if (need_comma) {
                q += ",";
            }
            q += "?";
            need_comma = true;
        }
        q += ")";
        //trace(q);
        if (!db.begin(q,lst,[])) {
            trace("Problem with database insert");
            return false;
        }
        db.end();
        return true;
    }

    public function attach(db: SqlDatabase, tag: String, resource_name: String) : Bool {
        // tag is controlled by us - no user input to sanitize
        if (!db.begin("ATTACH ? AS `" + tag + "`",[resource_name],[])) {
            trace("Failed to attach " + resource_name + " as " + tag);
            return false;
        }
        db.end();
        return true;
    }
}
