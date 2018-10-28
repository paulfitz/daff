// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class SqlCompare {
    public var db: SqlDatabase;
    public var local: SqlTable;
    public var remote: SqlTable;
    public var alt: SqlTable;
    private var at0 : Int;
    private var at1 : Int;
    private var at2 : Int;
    private var diff_ct : Int;
    private var align : Alignment;
    private var peered : Bool;
    private var alt_peered : Bool;
    private var needed : Array<Int>;
    private var flags : CompareFlags;

    public function new(db: SqlDatabase, local: SqlTable, remote: SqlTable,
                        alt: SqlTable, align: Alignment = null,
                        flags: CompareFlags = null) {
        this.db = db;
        this.local = local;
        this.remote = remote;
        this.alt = alt;
        this.align = align;
        this.flags = flags;
        if (this.flags==null) {
            this.flags = new CompareFlags();
        }
        peered = false;
        alt_peered = false;
        if (local!=null&&remote!=null) {
            if (this.remote.getDatabase().getNameForAttachment()!=null) {
                if (this.remote.getDatabase().getNameForAttachment()!=
                    this.local.getDatabase().getNameForAttachment()) {
                    local.getDatabase().getHelper().attach(db,"__peer__",this.remote.getDatabase().getNameForAttachment());
                    peered = true;
                }
            }
        }
        if (this.alt!=null&&local!=null) {
            if (this.alt.getDatabase().getNameForAttachment()!=null) {
                if (this.alt.getDatabase().getNameForAttachment()!=
                    this.local.getDatabase().getNameForAttachment()) {
                    local.getDatabase().getHelper().attach(db,"__alt__",this.alt.getDatabase().getNameForAttachment());
                    alt_peered = true;
                }
            }
        }
    }

    private function equalArray(a1: Array<String>, a2: Array<String>) : Bool {
        if (a1.length!=a2.length) return false;
        for (i in 0...a1.length) {
            if (a1[i]!=a2[i]) return false;
        }
        return true;
    }

    public function validateSchema() : Bool {
        var all_cols1 = [];
        var key_cols1 = [];
        var access_error = false;
        var pk_missing = false;
        if (local!=null) {
            all_cols1 = local.getColumnNames();
            key_cols1 = local.getPrimaryKey();
            if (all_cols1.length==0) access_error = true;
            if (flags.ids!=null) {
                key_cols1 = flags.getIdsByRole('local');
            }
            if (key_cols1.length==0) pk_missing = true;
        }
        var all_cols2 = [];
        var key_cols2 = [];
        if (remote!=null) {
            all_cols2 = remote.getColumnNames();
            key_cols2 = remote.getPrimaryKey();
            if (all_cols2.length==0) access_error = true;
            if (flags.ids!=null) {
                key_cols2 = flags.getIdsByRole('remote');
            }
            if (key_cols2.length==0) pk_missing = true;
        }
        var all_cols3 = all_cols2;
        var key_cols3 = key_cols2;
        if (alt!=null) {
            all_cols3 = alt.getColumnNames();
            key_cols3 = alt.getPrimaryKey();
            if (all_cols3.length==0) access_error = true;
            if (flags.ids!=null) {
                key_cols3 = flags.getIdsByRole('parent');
            }
            if (key_cols3.length==0) pk_missing = true;
        }
        if (access_error) {
            throw("Error accessing SQL table");
        }
        if (pk_missing) {
            throw("sql diff not possible when primary key not available");
        }
        var pk_change = false;
        if (local!=null&&remote!=null) {
            if (!equalArray(key_cols1,key_cols2)) pk_change = true;
        }
        if (local!=null&&alt!=null) {
            if (!equalArray(key_cols1,key_cols3)) pk_change = true;
        }
        if (pk_change) {
            throw("sql diff not possible when primary key changes: " +
                  [key_cols1, key_cols2, key_cols3]);
        }
        return true;
    }

    private function denull(x: Null<Int>) : Int {
        if (x==null) return -1;
        return x;
    }

    private function link() {
        diff_ct++;
        var mode : Int = db.get(0);
        var i0 = denull(db.get(1));
        var i1 = denull(db.get(2));
        var i2 = denull(db.get(3));
        if (i0==-3) {
            i0 = at0;
            at0++;
        }
        if (i1==-3) {
            i1 = at1;
            at1++;
        }
        if (i2==-3) {
            i2 = at2;
            at2++;
        }
        var offset = 4;
        if (i0>=0) {
            for (x in 0...local.width) {
                local.setCellCache(x,i0,db.get(x+offset));
            }
            offset += local.width;
        }
        if (i1>=0) {
            for (x in 0...remote.width) {
                remote.setCellCache(x,i1,db.get(x+offset));
            }
            offset += remote.width;
        }
        if (i2>=0) {
            for (x in 0...alt.width) {
                alt.setCellCache(x,i2,db.get(x+offset));
            }
        }
        if (mode==0||mode==2) {
            align.link(i0,i1);
            align.addToOrder(i0,i1);
        }
        if (alt!=null) {
            if (mode==1||mode==2) {
                align.reference.link(i0,i2);
                align.reference.addToOrder(i0,i2);
            }
        }
    }

    private function linkQuery(query: String, order: Array<String>) {
        if (db.begin(query,null,order)) {
            while (db.read()) {
                link();
            }
            db.end();
        }
    }

    private function where(txt: String) : String {
        if (txt=="") return " WHERE 1 = 0";
        return " WHERE " + txt;
    }

    public function scanColumns(all_cols1: Array<String>,
                                all_cols2: Array<String>,
                                key_cols: Array<String>,
                                present1: Map<String,Int>,
                                present2: Map<String,Int>,
                                align: Alignment) {
        align.meta = new Alignment();
        for (i in 0...(all_cols1.length)) {
            var key = all_cols1[i];
            if (present2.exists(key)) {
                align.meta.link(i,present2.get(key));
            } else {
                align.meta.link(i,-1);
            }
        }
        for (i in 0...(all_cols2.length)) {
            var key = all_cols2[i];
            if (!present1.exists(key)) {
                align.meta.link(-1,i);
            }
        }
        align.meta.range(all_cols1.length,all_cols2.length);
        for (key in key_cols) {
            var unit = new Unit(present1.get(key),present2.get(key));
            align.addIndexColumns(unit);
        }
    }

    // the sql we generate is a bit uglier than needed due to some
    // node-sqlite issues
    public function apply() : Alignment {
        if (db==null) return null;

        if (align==null) align = new Alignment();

        if (!validateSchema()) return null;

        var rowid_name : String = db.rowid();

        var key_cols = [];
        var data_cols = [];
        var all_cols = [];
        var all_cols1 = [];
        var all_cols2 = [];
        var all_cols3 = [];
        var common : SqlTable = local;

        if (local!=null) {
            key_cols = local.getPrimaryKey();
            data_cols = local.getAllButPrimaryKey();
            all_cols = local.getColumnNames();
            all_cols1 = local.getColumnNames();
            if (flags.ids!=null) {
                key_cols = flags.getIdsByRole('local');
                data_cols = new Array<String>();
                var pks = new Map<String, Bool>();
                for (col in key_cols) {
                    pks.set(col, true);
                }
                for (col in all_cols) {
                    if (!pks.exists(col)) {
                        data_cols.push(col);
                    }
                }
            }
        }

        if (remote!=null) {
            all_cols2 = remote.getColumnNames();
            if (common==null) common = remote;
        }

        if (alt!=null) {
            all_cols3 = alt.getColumnNames();
            if (common==null) common = alt;
        } else {
            all_cols3 = all_cols2;
        }

        var all_common_cols = new Array<String>();
        var data_common_cols = new Array<String>();

        var present1 = new Map<String,Int>();
        var present2 = new Map<String,Int>();
        var present3 = new Map<String,Int>();
        var present_primary = new Map<String,Int>();
        var has_column_add = false;

        for (i in 0...(key_cols.length)) {
            present_primary.set(key_cols[i],i);
        }
        for (i in 0...(all_cols1.length)) {
            var key = all_cols1[i];
            present1.set(key,i);
        }
        for (i in 0...(all_cols2.length)) {
            var key = all_cols2[i];
            if (!present1.exists(key)) {
                has_column_add = true;
            }
            present2.set(key,i);
        }
        for (i in 0...(all_cols3.length)) {
            var key = all_cols3[i];
            if (!present1.exists(key)) {
                has_column_add = true;
            }
            present3.set(key,i);
            if (present1.exists(key)) {
                if (present2.exists(key)) {
                    all_common_cols.push(key);
                    if (!present_primary.exists(key)) {
                        data_common_cols.push(key);
                    }
                }
            }
        }

        align.meta = new Alignment();
        for (i in 0...(all_cols1.length)) {
            var key = all_cols1[i];
            if (present2.exists(key)) {
                align.meta.link(i,present2.get(key));
            } else {
                align.meta.link(i,-1);
            }
        }
        for (i in 0...(all_cols2.length)) {
            var key = all_cols2[i];
            if (!present1.exists(key)) {
                align.meta.link(-1,i);
            }
        }
        scanColumns(all_cols1,all_cols2,key_cols,present1,present2,align);
        align.tables(local,remote);
        if (alt!=null) {
            scanColumns(all_cols1,all_cols3,key_cols,present1,present3,align.reference);
            align.reference.tables(local,alt);
        }

        var sql_table1 = "";
        var sql_table2 = "";
        var sql_table3 = "";
        if (local!=null) {
            sql_table1 = local.getQuotedTableName();
        }
        if (remote!=null) {
            sql_table2 = remote.getQuotedTableName();
        }
        if (alt!=null) {
            sql_table3 = alt.getQuotedTableName();
        }
        if (peered) {
            // the naming here is sqlite-specific
            sql_table1 = "main." + sql_table1;
            sql_table2 = "__peer__." + sql_table2;
        }
        if (alt_peered) {
            sql_table2 = "__alt__." + sql_table3;
        }
        var sql_key_cols: String = "";
        for (i in 0...(key_cols.length)) {
            if (i>0) sql_key_cols += ",";
            sql_key_cols += common.getQuotedColumnName(key_cols[i]);
        }
        var sql_all_cols: String = "";
        for (i in 0...(all_common_cols.length)) {
            if (i>0) sql_all_cols += ",";
            sql_all_cols += common.getQuotedColumnName(all_common_cols[i]);
        }
        var sql_all_cols1: String = "";
        for (i in 0...(all_cols1.length)) {
            if (i>0) sql_all_cols1 += ",";
            sql_all_cols1 += sql_table1 + "." + local.getQuotedColumnName(all_cols1[i]);
        }
        var sql_all_cols2: String = "";
        for (i in 0...(all_cols2.length)) {
            if (i>0) sql_all_cols2 += ",";
            sql_all_cols2 += sql_table2 + "." + remote.getQuotedColumnName(all_cols2[i]);
        }
        var sql_all_cols3: String = "";
        if (alt!=null) {
            for (i in 0...(all_cols3.length)) {
                if (i>0) sql_all_cols3 += ",";
                sql_all_cols3 += sql_table3 + "." + alt.getQuotedColumnName(all_cols3[i]);
            }
        }
        var sql_key_null : String = "";
        for (i in 0...(key_cols.length)) {
            if (i>0) sql_key_null += " AND ";
            var n : String = common.getQuotedColumnName(key_cols[i]);
            sql_key_null += sql_table1 + "." + n + " IS NULL";
        }
        var sql_key_null2 : String = "";
        for (i in 0...(key_cols.length)) {
            if (i>0) sql_key_null2 += " AND ";
            var n : String = common.getQuotedColumnName(key_cols[i]);
            sql_key_null2 += sql_table2 + "." + n + " IS NULL";
        }
        var sql_key_match2 : String = "";
        for (i in 0...(key_cols.length)) {
            if (i>0) sql_key_match2 += " AND ";
            var n : String = common.getQuotedColumnName(key_cols[i]);
            sql_key_match2 += sql_table1 + "." + n + " IS " + sql_table2 + "." + n;
        }
        var sql_key_match3 : String = "";
        if (alt!=null) {
            for (i in 0...(key_cols.length)) {
                if (i>0) sql_key_match3 += " AND ";
                var n : String = common.getQuotedColumnName(key_cols[i]);
                sql_key_match3 += sql_table1 + "." + n + " IS " + sql_table3 + "." + n;
            }
        }
        var sql_data_mismatch : String = "";
        for (i in 0...(data_common_cols.length)) {
            if (i>0) sql_data_mismatch += " OR ";
            var n : String = common.getQuotedColumnName(data_common_cols[i]);
            sql_data_mismatch += sql_table1 + "." + n + " IS NOT " + sql_table2 + "." + n;
        }
        for (i in 0...(all_cols2.length)) {
            var key = all_cols2[i];
            if (!present1.exists(key)) {
                if (sql_data_mismatch!="") sql_data_mismatch += " OR ";
                var n : String = common.getQuotedColumnName(key);
                sql_data_mismatch += sql_table2 + "." + n + " IS NOT NULL";
            }
        }
        if (alt!=null) {
            for (i in 0...(data_common_cols.length)) {
                if (sql_data_mismatch.length>0) sql_data_mismatch += " OR ";
                var n : String = common.getQuotedColumnName(data_common_cols[i]);
                sql_data_mismatch += sql_table1 + "." + n + " IS NOT " + sql_table3 + "." + n;
            }
            for (i in 0...(all_cols3.length)) {
                var key = all_cols3[i];
                if (!present1.exists(key)) {
                    if (sql_data_mismatch!="") sql_data_mismatch += " OR ";
                    var n : String = common.getQuotedColumnName(key);
                    sql_data_mismatch += sql_table3 + "." + n + " IS NOT NULL";
                }
            }
        }
        var sql_dbl_cols: String = "";
        var dbl_cols: Array<String> = [];
        for (i in 0...(all_cols1.length)) {
            if (sql_dbl_cols!="") sql_dbl_cols += ",";
            var buf : String = "__coopy_" + i;
            var n : String = common.getQuotedColumnName(all_cols1[i]);
            sql_dbl_cols += sql_table1 + "." + n + " AS " + buf;
            dbl_cols.push(buf);
        }
        for (i in 0...(all_cols2.length)) {
            if (sql_dbl_cols!="") sql_dbl_cols += ",";
            var buf : String = "__coopy_" + i + "b";
            var n : String = common.getQuotedColumnName(all_cols2[i]);
            sql_dbl_cols += sql_table2 + "." + n + " AS " + buf;
            dbl_cols.push(buf);
        }
        if (alt!=null) {
            for (i in 0...(all_cols3.length)) {
                if (sql_dbl_cols!="") sql_dbl_cols += ",";
                var buf : String = "__coopy_" + i + "c";
                var n : String = common.getQuotedColumnName(all_cols3[i]);
                sql_dbl_cols += sql_table3 + "." + n + " AS " + buf;
                dbl_cols.push(buf);
            }
        }
        var sql_order: String = "";
        for (i in 0...(key_cols.length)) {
            if (i>0) sql_order += ",";
            var n : String = common.getQuotedColumnName(key_cols[i]);
            sql_order += n;
        }
        
        var rowid : String = "-3";
        var rowid1 : String = "-3";
        var rowid2 : String = "-3";
        var rowid3 : String = "-3";
        if (rowid_name!=null) {
            rowid = rowid_name;
            if (local!=null) {
                rowid1 = sql_table1 + "." + rowid_name;
            }
            if (remote!=null) {
                rowid2 = sql_table2 + "." + rowid_name;
            }
            if (alt!=null) {
                rowid3 = sql_table3 + "." + rowid_name;
            }
        }

        at0 = 1;
        at1 = 1;
        at2 = 1;
        diff_ct = 0;

        if (remote!=null) {
            var sql_inserts : String = "SELECT DISTINCT 0 AS __coopy_code, NULL, " + rowid2 + " AS rowid, NULL, " + sql_all_cols2 + " FROM " + sql_table2;
            if (local!=null) {
                sql_inserts += " LEFT JOIN " + sql_table1;
                sql_inserts += " ON " + sql_key_match2 + where(sql_key_null);
            }
            if (sql_table1!=sql_table2) {
                var sql_inserts_order : Array<String> = ["__coopy_code","NULL","rowid","NULL"].concat(all_cols2);
                linkQuery(sql_inserts,sql_inserts_order);
            }
        }

        if (alt!=null) {
            var sql_inserts : String = "SELECT DISTINCT 0 AS __coopy_code, NULL, NULL, " + rowid3 + " AS rowid, " + sql_all_cols3 + " FROM " + sql_table3;
            if (local!=null) {
                sql_inserts += " LEFT JOIN " + sql_table1;
                sql_inserts += " ON " + sql_key_match3 + where(sql_key_null);
            }
            if (sql_table1!=sql_table3) {
                var sql_inserts_order : Array<String> = ["__coopy_code","NULL","NULL","rowid"].concat(all_cols3);
                linkQuery(sql_inserts,sql_inserts_order);
            }
        }

        if (local!=null && remote!=null) {
            var sql_updates : String = "SELECT DISTINCT 2 AS __coopy_code, " + rowid1 + " AS __coopy_rowid0, " + rowid2 + " AS __coopy_rowid1, ";
            if (alt!=null) {
                sql_updates += rowid3 + " AS __coopy_rowid2,";
            } else {
                sql_updates += " NULL,";
            }
            sql_updates += sql_dbl_cols + " FROM " + sql_table1;
            if (sql_table1 != sql_table2) {
                sql_updates += " INNER JOIN " + sql_table2 + " ON " + sql_key_match2;
            }
            if (alt!=null && sql_table1 != sql_table3) {
                sql_updates += " INNER JOIN " + sql_table3 + " ON " + sql_key_match3;
            }
            sql_updates += where(sql_data_mismatch);
            var sql_updates_order : Array<String> = ["__coopy_code","__coopy_rowid0","__coopy_rowid1","__coopy_rowid2"].concat(dbl_cols);
            linkQuery(sql_updates,sql_updates_order);
        }

        if (alt==null) {
            if (local!=null) {
                var sql_deletes : String = "SELECT DISTINCT 0 AS __coopy_code, " + rowid1 + " AS rowid, NULL, NULL, " + sql_all_cols1 + " FROM " + sql_table1;
                if (remote!=null) {
                    sql_deletes += " LEFT JOIN " + sql_table2;
                    sql_deletes += " ON " + sql_key_match2 + where(sql_key_null2);
                }
                if (sql_table1!=sql_table2) {
                    var sql_deletes_order : Array<String> = ["__coopy_code","rowid","NULL","NULL"].concat(all_cols1);
                    linkQuery(sql_deletes,sql_deletes_order);
                }
            }
        }

        if (alt!=null) {

            var sql_deletes : String = "SELECT 2 AS __coopy_code, " + rowid1 + " AS __coopy_rowid0, " + rowid2 + " AS __coopy_rowid1, ";
            sql_deletes += rowid3 + " AS __coopy_rowid2, ";
            sql_deletes += sql_dbl_cols;
            sql_deletes += " FROM " + sql_table1;
            if (remote!=null) {
                sql_deletes += " LEFT OUTER JOIN " + sql_table2 + " ON " + sql_key_match2;
            }
            sql_deletes += " LEFT OUTER JOIN " + sql_table3 + " ON " + sql_key_match3;
            sql_deletes += " WHERE __coopy_rowid1 IS NULL OR __coopy_rowid2 IS NULL";
            var sql_deletes_order : Array<String> = ["__coopy_code","__coopy_rowid0","__coopy_rowid1","__coopy_rowid2"].concat(dbl_cols);
            linkQuery(sql_deletes,sql_deletes_order);
        }

        if (diff_ct==0) {
            align.markIdentical();
        }

        return align;
    }
}

