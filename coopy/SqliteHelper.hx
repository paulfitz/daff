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
            q += " IS ?";
            lst.push(conds.get(k));
        }
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
        if (!db.begin(q,lst,[])) {
            trace("Problem with database insert");
            return false;
        }
        db.end();
        return true;
    }

    public function attach(db: SqlDatabase, tag: String, resource_name: String) : Bool {
        var tag_present = false;
        var tag_correct = false;
        var result = new Array<Int>();
        var q = "PRAGMA database_list";
        if (!db.begin(q,null,["seq","name","file"])) return false;
        while (db.read()) {
            var name : String = cast db.get(1);
            if (name == tag) {
                tag_present = true;
                var file : String = cast db.get(2);
                if (file == resource_name) {
                    tag_correct = true;
                }
            }
        }
        db.end();

        if (tag_present) {
            if (tag_correct) return true;
            // tag is controlled by us - no user input to sanitize
            if (!db.begin("DETACH `" + tag + "`",null,[])) {
                trace("Failed to detach " + tag);
                return false;
            }
            db.end();
        }

        if (!db.begin("ATTACH ? AS `" + tag + "`",[resource_name],[])) {
            trace("Failed to attach " + resource_name + " as " + tag);
            return false;
        }
        db.end();
        return true;
    }

    private function columnListSql(x: Array<String>) {
        return x.join(",");
    }

    private function fetchSchema(db: SqlDatabase, name: SqlTableName) : String {
        var tname = db.getQuotedTableName(name);
        var query = "select sql from sqlite_master where name = " + tname;
        if (!db.begin(query,null,["sql"])) {
            trace("Cannot find schema for table " + tname);
            return null;
        }
        var sql = "";
        if (db.read()) {
            sql = db.get(0);
        }
        db.end();
        return sql;
    }

    private function splitSchema(db: SqlDatabase, name: SqlTableName, sql: String) {
        var preamble = "";
        var parts = new Array<String>();

        var double_quote = false;
        var single_quote = false;
        var token = "";
        var nesting = 0;
        for (i in 0...sql.length) {
            var ch = sql.charAt(i);
            if (double_quote||single_quote) {
                if (double_quote) {
                    if (ch=='\"') double_quote = false;
                }
                if (single_quote) {
                    if (ch=='\'') single_quote = false;
                }
                token += ch;
                continue;
            }
            var brk = false;
            if (ch=='(') {
                nesting++;
                if (nesting==1) {
                    brk = true;
                }
            } else if (ch==')') {
                nesting--;
                if (nesting==0) {
                    brk = true;
                }
            }
            if (ch==',') {
                brk = true;
                if (nesting==1) {
                }
            }
            if (brk) {
                if (token.charAt(0)==' ') {
                    token = token.substr(1,token.length);
                }
                if (preamble=="") {
                    preamble = token;
                } else {
                    parts.push(token);
                }
                token = "";
            } else {
                token += ch;
            }
        }
        var cols = db.getColumns(name);
        var name2part = new Map<String,String>();
        var name2col = new Map<String,SqlColumn>();
        for (i in 0...cols.length) {
            var col = cols[i];
            name2part.set(col.name,parts[i]);
            name2col.set(col.name,cols[i]);
        }
        return {
                "preamble": preamble,
                "parts": parts,
                "name2part": name2part,
                "columns": cols,
                "name2column": name2col
                };
    }

    private function exec(db: SqlDatabase, query: String) : Bool {
        if (!db.begin(query)) {
            trace("database problem");
            return false;
        }
        db.end();
        return true;
    }

    public function alterColumns(db: SqlDatabase, name: SqlTableName,
                                 columns : Array<ColumnChange>) : Bool {
        // In Sqlite, we basically have to rip a table down and build it up from scratch.
        // Exception: we could add columns non-destructively (but don't yet).

        var notBlank = function(x:String) {
            if (x==null || x=="" || x=="null") {
                return false;
            }
            return true;
        }

        var sql = fetchSchema(db,name);
        var schema = splitSchema(db,name,sql);
        var parts = schema.parts;
        var nparts = new Array<String>();

        var new_column_list = new Array<String>();
        var ins_column_list = new Array<String>();
        var sel_column_list = new Array<String>();
        var meta = schema.columns;
        for (i in 0...columns.length) {
            var c = columns[i];
            if (c.name!=null) {
                if (c.prevName!=null) {
                    sel_column_list.push(c.prevName);
                    ins_column_list.push(c.name);
                }
                var orig_type = "";
                var orig_primary = false;
                if (schema.name2column.exists(c.name)) {
                    var m = schema.name2column.get(c.name);
                    orig_type = m.type_value;
                    orig_primary = m.primary;
                }
                var next_type = orig_type;
                var next_primary = orig_primary;
                if (c.props!=null) {
                    for (p in c.props) {
                        if (p.name == "type") {
                            next_type = p.val;
                        }
                        if (p.name == "key") {
                            next_primary = (""+p.val == "primary");
                        }
                    }
                }
                var part = "" + c.name;
                if (notBlank(next_type)) {
                    part += " " + next_type;
                }
                if (next_primary) {
                    part += " PRIMARY KEY";
                }
                nparts.push(part);
                new_column_list.push(c.name);
            }
        }
        if (!exec(db,"BEGIN TRANSACTION")) return false;
        var c1 = columnListSql(ins_column_list);
        var tname = db.getQuotedTableName(name);
        if (!exec(db,"CREATE TEMPORARY TABLE __coopy_backup(" + c1 + ")")) return false;
        if (!exec(db,"INSERT INTO __coopy_backup (" + c1 + ") SELECT " + c1 + " FROM " + tname)) return false;
        if (!exec(db,"DROP TABLE " + tname)) return false;
        if (!exec(db,schema.preamble + "(" + nparts.join(", ") + ")")) return false;
        if (!exec(db,"INSERT INTO " + tname + " (" + c1 + ") SELECT " + c1 + " FROM __coopy_backup")) return false;
        if (!exec(db,"DROP TABLE __coopy_backup")) return false;
        if (!exec(db,"COMMIT")) return false;
        return true;
    }
}
