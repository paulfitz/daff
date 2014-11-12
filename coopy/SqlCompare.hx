// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class SqlCompare {
    public var db: SqlDatabase;
    public var parent: SqlTable;
    public var local: SqlTable;
    public var remote: SqlTable;
    private var at0 : Int;
    private var at1 : Int;
    private var align : Alignment;

    public function new(db: SqlDatabase, local: SqlTable, remote: SqlTable) {
        this.db = db;
        this.local = local;
        this.remote = remote;
    }

    private function equalArray(a1: Array<String>, a2: Array<String>) : Bool {
        if (a1.length!=a2.length) return false;
        for (i in 0...a1.length) {
            if (a1[i]!=a2[i]) return false;
        }
        return true;
    }

    public function validateSchema() : Bool {
        var all_cols1 = local.getColumnNames();
        var all_cols2 = remote.getColumnNames();
        if (!equalArray(all_cols1,all_cols2)) { 
            return false;
        }
        var key_cols1 = local.getPrimaryKey();
        var key_cols2 = remote.getPrimaryKey();
        if (!equalArray(key_cols1,key_cols2)) {
            return false;
        }
        if (key_cols1.length==0) {
            return false;
        }
        return true;
    }

    private function denull(x: Null<Int>) : Int {
        if (x==null) return -1;
        return x;
    }

    private function link() {
        var i0 = denull(db.get(0));
        var i1 = denull(db.get(1));
        if (i0==-3) {
            i0 = at0;
            at0++;
        }
        if (i1==-3) {
            i1 = at1;
            at1++;
        }
        var factor = (i0>=0 && i1>=0) ? 2 : 1;
        var offset = factor - 1;
        if (i0>=0) {
            for (x in 0...local.width) {
                local.setCellCache(x,i0,db.get(2+factor*x));
            }
        }
        if (i1>=0) {
            for (x in 0...remote.width) {
                remote.setCellCache(x,i1,db.get(2+factor*x+offset));
            }
        }
        align.link(i0,i1);
        align.addToOrder(i0,i1);
    }

    private function linkQuery(query: String, order: Array<String>) {
        if (db.begin(query,null,order)) {
            while (db.read()) {
                link();
            }
            db.end();
        }
    }

    // the sql we generate is a bit uglier than needed due to some
    // node-sqlite issues
    public function apply() : Alignment {
        if (db==null) return null;
        if (!validateSchema()) return null;

        var rowid_name : String = db.rowid();

        align = new Alignment();

        var key_cols = local.getPrimaryKey();
        var data_cols = local.getAllButPrimaryKey();
        var all_cols = local.getColumnNames();

        // for the moment expect all columns to match
        align.meta = new Alignment();
        for (i in 0...(all_cols.length)) {
            align.meta.link(i,i);
        }
        align.meta.range(all_cols.length,all_cols.length);

        align.tables(local,remote);
        align.range(999,999);

        var sql_table1 = local.getQuotedTableName();
        var sql_table2 = remote.getQuotedTableName();
        var sql_key_cols: String = "";
        for (i in 0...(key_cols.length)) {
            if (i>0) sql_key_cols += ",";
            sql_key_cols += local.getQuotedColumnName(key_cols[i]);
        }
        var sql_all_cols: String = "";
        for (i in 0...(all_cols.length)) {
            if (i>0) sql_all_cols += ",";
            sql_all_cols += local.getQuotedColumnName(all_cols[i]);
        }
        var sql_key_match : String = "";
        for (i in 0...(key_cols.length)) {
            if (i>0) sql_key_match += " AND ";
            var n : String = local.getQuotedColumnName(key_cols[i]);
            sql_key_match += sql_table1 + "." + n + " IS " + sql_table2 + "." + n;
        }
        var sql_data_mismatch : String = "";
        for (i in 0...(data_cols.length)) {
            if (i>0) sql_data_mismatch += " OR ";
            var n : String = local.getQuotedColumnName(data_cols[i]);
            sql_data_mismatch += sql_table1 + "." + n + " IS NOT " + sql_table2 + "." + n;
        }
        var sql_dbl_cols: String = "";
        var dbl_cols: Array<String> = [];
        for (i in 0...(all_cols.length)) {
            if (i>0) sql_dbl_cols += ",";
            var n : String = local.getQuotedColumnName(all_cols[i]);
            var buf : String = "__coopy_" + i;
            sql_dbl_cols += sql_table1 + "." + n + " AS " + buf;
            dbl_cols.push(buf);
            sql_dbl_cols += ",";
            sql_dbl_cols += sql_table2 + "." + n + " AS " + buf + "b";
            dbl_cols.push(buf + "b");
        }
        var sql_order: String = "";
        for (i in 0...(key_cols.length)) {
            if (i>0) sql_order += ",";
            var n : String = local.getQuotedColumnName(key_cols[i]);
            sql_order += n;
        }
        var sql_dbl_order: String = "";
        for (i in 0...(key_cols.length)) {
            if (i>0) sql_dbl_order += ",";
            var n : String = local.getQuotedColumnName(key_cols[i]);
            sql_dbl_order += sql_table1 + "." + n;
        }
        
        var rowid : String = "-3";
        var rowid1 : String = "-3";
        var rowid2 : String = "-3";
        if (rowid_name!=null) {
            rowid = rowid_name;
            rowid1 = sql_table1 + "." + rowid_name;
            rowid2 = sql_table2 + "." + rowid_name;
        }

        var sql_inserts : String = "SELECT DISTINCT NULL, " + rowid + " AS rowid, " + sql_all_cols + " FROM " + sql_table2 + " WHERE NOT EXISTS (SELECT 1 FROM " + sql_table1 + " WHERE " + sql_key_match + ")";
        var sql_inserts_order : Array<String> = ["NULL","rowid"].concat(all_cols);
        var sql_updates : String = "SELECT DISTINCT " + rowid1 + " AS __coopy_rowid0, " + rowid2 + " AS __coopy_rowid1, " + sql_dbl_cols + " FROM " + sql_table1 + " INNER JOIN " + sql_table2 + " ON " + sql_key_match + " WHERE " + sql_data_mismatch;
        // + " ORDER BY " + sql_dbl_order;
        var sql_updates_order : Array<String> = ["__coopy_rowid0", "__coopy_rowid1"].concat(dbl_cols);
        var sql_deletes : String = "SELECT DISTINCT " + rowid + " AS rowid, NULL, " + sql_all_cols + " FROM " + sql_table1 + " WHERE NOT EXISTS (SELECT 1 FROM " + sql_table2 + " WHERE " + sql_key_match + ")";
        var sql_deletes_order : Array<String> = ["rowid","NULL"].concat(all_cols);
 
        at0 = 1;
        at1 = 1;
        linkQuery(sql_inserts,sql_inserts_order);
        linkQuery(sql_updates,sql_updates_order);
        linkQuery(sql_deletes,sql_deletes_order);
        
        return align;
    }
}

