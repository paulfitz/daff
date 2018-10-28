// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Run a comparison between tables.  Normally you'll
 * call `coopy.Coopy.compareTables` to start off such a comparison.
 *
 */
@:expose
class CompareTable {
    private var comp: TableComparisonState;
    private var indexes : Array<IndexPair>;

    /**
     *
     * @param comp the state of the comparison, including the tables to
     * be compared, and whether the comparison has run to completion.
     *
     */
    public function new(comp: TableComparisonState) {
        this.comp = comp;
        if (comp.compare_flags!=null) {
            if (comp.compare_flags.parent!=null) {
                comp.p = comp.compare_flags.parent;
            }
        }
    }

    /**
     *
     * Run or continue the comparison.
     *
     * @return true if `run()` needs to be called again to do more work
     *
     */
    public function run() : Bool {
        if (useSql()) {
            comp.completed = true;
            return false;
        }
        var more : Bool = compareCore();
        while (more && comp.run_to_completion) {
            more = compareCore();
        }
        return !more;
    }

    /**
     *
     * Access a summary of how the tables align with each other.
     * Runs the comparison to completion if it hasn't already been
     * finished.
     *
     * @return the alignment between tables
     *
     */
    public function align() : Alignment {
        while (!comp.completed) {
            run();
        }
        var alignment : Alignment = new Alignment();
        alignCore(alignment);
        // squirrel away state in case we need to do nested comparisons
        alignment.comp = comp;
        comp.alignment = alignment;
        return alignment;
    }

    /**
     *
     * @return the state of the comparison (the tables involved, if the
     * comparison has completed, etc)
     *
     */
    public function getComparisonState() : TableComparisonState {
        return comp;
    }

    private function alignCore(align: Alignment) : Void {
        if (useSql()) {
            var tab1 : SqlTable = null;
            var tab2 : SqlTable = null;
            var tab3 : SqlTable = null;
            if (comp.p==null) {
                tab1 = cast comp.a;
                tab2 = cast comp.b;
            } else {
                align.reference = new Alignment();
                tab1 = cast comp.p;
                tab2 = cast comp.b;
                tab3 = cast comp.a;
            }
            var db : SqlDatabase = null;
            if (tab1!=null) db = tab1.getDatabase();
            if (db==null && tab2!=null) db = tab2.getDatabase();
            if (db==null && tab3!=null) db = tab3.getDatabase();
            var sc = new SqlCompare(db,tab1,tab2,tab3,align,comp.compare_flags);
            sc.apply();
            if (comp.p!=null) {
                align.meta.reference = align.reference.meta;
            }
            return;
        }
        if (comp.p==null) {
            alignCore2(align,comp.a,comp.b);
            return;
        }
        align.reference = new Alignment();
        alignCore2(align,comp.p,comp.b);
        alignCore2(align.reference,comp.p,comp.a);
        align.meta.reference = align.reference.meta;
    }


    private function alignCore2(align: Alignment,
                                a: Table, b: Table) : Void {
        if (align.meta == null) {
            align.meta = new Alignment();
        }
        alignColumns(align.meta,a,b);
        var column_order : Ordering = align.meta.toOrder();

        align.range(a.height,b.height);
        align.tables(a,b);
        align.setRowlike(true);
        
        var w : Int = a.width;
        var ha : Int = a.height;
        var hb : Int = b.height;

        var av : View = a.getCellView();

        var ids : Array<String> = null;
        var ignore : Map<String,Bool> = null;
        var ordered : Bool = true;
        if (comp.compare_flags!=null) {
            ids = comp.compare_flags.ids;
            ignore = comp.compare_flags.getIgnoredColumns();
            ordered = comp.compare_flags.ordered;
        }
 
        var common_units : Array<Unit> = new Array<Unit>();
        var ra_header : Int = align.getSourceHeader();
        var rb_header : Int = align.getSourceHeader();
        for (unit in column_order.getList()) {
            if (unit.l>=0 && unit.r>=0 && unit.p!=-1) {
                if (ignore!=null) {
                    if (unit.l>=0 && ra_header>=0 && ra_header<a.height) {
                        var name = av.toString(a.getCell(unit.l,ra_header));
                        if (ignore.exists(name)) continue;
                    }
                    if (unit.r>=0 && rb_header>=0 && rb_header<b.height) {
                        var name = av.toString(b.getCell(unit.r,rb_header));
                        if (ignore.exists(name)) continue;
                    }
                }
                common_units.push(unit);
            }
        }

        var index_top : IndexPair = null;
        var pending_ct : Int = ha;
        var reverse_pending_ct : Int = hb;
        var used : Map<Int,Int> = new Map<Int,Int>();
        var used_reverse : Map<Int,Int> = new Map<Int,Int>();
        if (ids!=null) {
            // no need for heuristics, we've been told what columns
            // to use as a primary key

            index_top = new IndexPair(comp.compare_flags);
            var ids_as_map = new Map<String,Bool>();
            for (id in ids) {
                ids_as_map[id] = true;
            }
            for (unit in common_units) {
                var na = av.toString(a.getCell(unit.l,0));
                var nb = av.toString(b.getCell(unit.r,0));
                if (ids_as_map.exists(na)||ids_as_map.exists(nb)) {
                    index_top.addColumns(unit.l,unit.r);
                    align.addIndexColumns(unit);
                }
            }
            index_top.indexTables(a,b,1);
            if (indexes!=null) {
                indexes.push(index_top);
            }
            for (j in 0...ha) {
                var cross: CrossMatch = index_top.queryLocal(j);
                var spot_a : Int = cross.spot_a;
                var spot_b : Int = cross.spot_b;
                if (spot_a!=1 || spot_b!=1) continue;
                var jb = cross.item_b.value();
                align.link(j,jb);
                used.set(jb,1);
                if (!used_reverse.exists(j)) reverse_pending_ct--;
                used_reverse.set(j,1);
            }
        } else {
            // heuristics needed

            // If we have more columns than we have time to process their
            // combinations, we need to haul out some heuristics.
            
            var N : Int = 5;
            var columns : Array<Int> = new Array<Int>();
            if (common_units.length>N) {
                var columns_eval : Array<Array<Int>> = new Array<Array<Int>>();
                for (i in 0...common_units.length) {
                    var ct: Int = 0;
                    var mem: Map<String,Int> = new Map<String,Int>();
                    var mem2: Map<String,Int> = new Map<String,Int>();
                    var ca: Int = common_units[i].l;
                    var cb: Int = common_units[i].r;
                    for (j in 0...ha) {
                        var key: String = av.toString(a.getCell(ca,j));
                        if (!mem.exists(key)) {
                            mem.set(key,1);
                            ct++;
                        }
                    }
                    for (j in 0...hb) {
                        var key: String = av.toString(b.getCell(cb,j));
                        if (!mem2.exists(key)) {
                            mem2.set(key,1);
                            ct++;
                        }
                    }
                    columns_eval.push([i,ct]);
                }
                var sorter = function(a,b) {
                    if (a[1]<b[1]) return 1;
                    if (a[1]>b[1]) return -1;
                    if (a[0]>b[0]) return 1;
                    if (a[0]<b[0]) return -1;
                    return 0;
                }
                columns_eval.sort(sorter);
                columns = Lambda.array(Lambda.map(columns_eval, function(v) { return v[0]; }));
                columns = columns.slice(0,N);
            } else {
                for (i in 0...common_units.length) {
                    columns.push(i);
                }
            }

            var top : Int = Math.round(Math.pow(2,columns.length));

            var pending : Map<Int,Int> = new Map<Int,Int>();
            for (j in 0...ha) {
                pending.set(j,j);
            }

            var added_columns: Map<Int,Bool> = new Map<Int,Bool>();
            var index_ct : Int = 0;
        
            for (k in 0...top) {
                if (k==0) continue;
                if (pending_ct == 0) break;
                var active_columns : Array<Int> = new Array<Int>();
                var kk : Int = k;
                var at : Int = 0;
                while (kk>0) {
                    if (kk%2==1) {
                        active_columns.push(columns[at]);
                    }
                    kk >>= 1;
                    at++;
                }

                var index : IndexPair = new IndexPair(comp.compare_flags);
                for (k in 0...active_columns.length) {
                    var col : Int = active_columns[k];
                    var unit : Unit = common_units[col];
                    index.addColumns(unit.l,unit.r);
                    if (!added_columns.exists(col)) {
                        align.addIndexColumns(unit);
                        added_columns.set(col,true);
                    }
                }
                index.indexTables(a,b,1);
                if (k==top-1) index_top = index;

                var h : Int = a.height;
                if (b.height>h) h = b.height;
                if (h<1) h = 1;
                var wide_top_freq : Int = index.getTopFreq();
                var ratio : Float = wide_top_freq;
                ratio /= (h+20); // "20" allows for low-data 
                if (ratio>=0.1) {
                    // lousy no-good index, we should move on
                    if (index_ct>0 || k<top-1) continue;
                    // but unfortunately we have nothing better
                }

                index_ct++;
                if (indexes!=null) {
                    indexes.push(index);
                }

                var fixed : Array<Int> = new Array<Int>();
                for (j in pending.keys()) {
                    var cross: CrossMatch = index.queryLocal(j);
                    var spot_a : Int = cross.spot_a;
                    var spot_b : Int = cross.spot_b;
                    if (spot_a!=1 || spot_b!=1) continue;
                    var val = cross.item_b.value();
                    if (!used.exists(val)) {
                        fixed.push(j);
                        align.link(j,val);
                        used.set(val,1);
                        if (!used_reverse.exists(j)) reverse_pending_ct--;
                        used_reverse.set(j,1);
                    }
                }
                for (j in 0...fixed.length) {
                    pending.remove(fixed[j]);
                    pending_ct--;
                }
            }
        }
        if (index_top!=null) {
            // small optimization for duplicated lines,
            // add them to alignment if it is a clear win
            // to do so
            var offset : Int = 0;
            var scale : Int = 1;
            for (sgn in 0...2) {
                if (pending_ct>0) {
                    var xb : Null<Int> = null;
                    if (scale==-1 && hb>0) xb = hb-1;
                    for (xa0 in 0...ha) {
                        var xa : Int = xa0*scale + offset;
                        var xb2 : Null<Int> = align.a2b(xa);
                        if (xb2!=null) {
                            xb = xb2+scale;
                            if (xb>=hb||xb<0) break;
                            continue;
                        }
                        if (xb==null) continue;
                        var ka = index_top.localKey(xa);
                        var kb = index_top.remoteKey(xb);
                        if (ka!=kb) continue;
                        if (used.exists(xb)) continue;
                        align.link(xa,xb);
                        used.set(xb,1);
                        used_reverse.set(xa,1);
                        pending_ct--;
                        xb+=scale;
                        if (xb>=hb||xb<0) break;
                        if (pending_ct==0) break;
                    }
                }
                offset = ha-1;
                scale = -1;
            }
            offset = 0;
            scale = 1;
            for (sgn in 0...2) {
                if (reverse_pending_ct>0) {
                    var xa : Null<Int> = null;
                    if (scale==-1 && ha>0) xa = ha-1;
                    for (xb0 in 0...hb) {
                        var xb : Int = xb0*scale + offset;
                        var xa2 : Null<Int> = align.b2a(xb);
                        if (xa2!=null) {
                            xa = xa2+scale;
                            if (xa>=ha||xa<0) break;
                            continue;
                        }
                        if (xa==null) continue;
                        var ka = index_top.localKey(xa);
                        var kb = index_top.remoteKey(xb);
                        if (ka!=kb) continue;
                        if (used_reverse.exists(xa)) continue;
                        align.link(xa,xb);
                        used.set(xb,1);
                        used_reverse.set(xa,1);
                        reverse_pending_ct--;
                        xa+=scale;
                        if (xa>=ha||xa<0) break;
                        if (reverse_pending_ct==0) break;
                    }
                }
                offset = hb-1;
                scale = -1;
            }
        }
        // for consistency, explicitly mark unaligned things
        for (i in 1...ha) {
            if (!used_reverse.exists(i)) {
                align.link(i,-1);
            }
        }
        for (i in 1...hb) {
            if (!used.exists(i)) {
                align.link(-1,i);
            }
        }
        // we expect headers on row 0 - link them even if quite different.
        if (ha>0 && hb>0) {
            align.link(0,0);
            align.headers(0,0);
        }
    }

    private function alignColumns(align: Alignment, a: Table, b: Table) : Void {
        align.range(a.width,b.width);
        align.tables(a,b);
        align.setRowlike(false);
        
        var slop : Int = 5;
        
        var va : View = a.getCellView();
        var vb : View = b.getCellView();
        var ra_best : Int = 0;
        var rb_best : Int = 0;
        var ct_best : Int = -1;
        var ma_best : Map<String,Int> = null;
        var mb_best : Map<String,Int> = null;
        var ra_header : Int = 0;
        var rb_header : Int = 0;
        var ra_uniques : Int = 0;
        var rb_uniques : Int = 0;
        for (ra in 0...slop) {
            for (rb in 0...slop) {
                var ma : Map<String,Int> = new Map<String,Int>();
                var mb : Map<String,Int> = new Map<String,Int>();
                var ct : Int = 0;
                var uniques : Int = 0;
                if (ra<a.height) {
                    for (ca in 0...a.width) {
                        var key : String = va.toString(a.getCell(ca,ra));
                        if (ma.exists(key)) {
                            ma.set(key,-1);
                            uniques--;
                        } else {
                        ma.set(key,ca);
                        uniques++;
                        }
                    }
                    if (uniques>ra_uniques) {
                        ra_header = ra;
                        ra_uniques = uniques;
                    }
                }
                uniques = 0;
                if (rb<b.height) {
                    for (cb in 0...b.width) {
                        var key : String = vb.toString(b.getCell(cb,rb));
                        if (mb.exists(key)) {
                            mb.set(key,-1);
                            uniques--;
                        } else {
                            mb.set(key,cb);
                            uniques++;
                        }
                    }
                    if (uniques>rb_uniques) {
                        rb_header = rb;
                        rb_uniques = uniques;
                    }
                }

                for (key in ma.keys()) {
                    var i0 : Int = ma.get(key);
                    var i1 : Null<Int> = mb.get(key);
                    if (i1!=null) {
                        if (i1>=0 && i0>=0) {
                            ct++;
                        }
                    }
                }

                if (ct>ct_best) {
                    ct_best = ct;
                    ma_best = ma;
                    mb_best = mb;
                    ra_best = ra;
                    rb_best = rb;
                }
            }
        }

        if (ma_best==null) {
            if (a.height>0 && b.height==0) {
                align.headers(0,-1);
            } else if (a.height==0 && b.height>0) {
                align.headers(-1,0);
            }
            return;
        }
        for (key in ma_best.keys()) {
            var i0 : Null<Int> = ma_best.get(key);
            var i1 : Null<Int> = mb_best.get(key);
            if (i0!=null && i1!=null) {
                align.link(i0,i1);
            } else if (i0!=null) {
                align.link(i0,-1);
            } else if (i1!=null) {
                align.link(-1,i1);
            }
        }
        for (key in mb_best.keys()) {
            var i0 : Null<Int> = ma_best.get(key);
            var i1 : Null<Int> = mb_best.get(key);
            if (i0==null&&i1!=null) {
                align.link(-1,i1);
            }
        }
        align.headers(ra_header,rb_header);
    }

    private function testHasSameColumns() : Bool {
        var p : Table = comp.p;
        var a : Table = comp.a;
        var b : Table = comp.b;
        var eq : Bool = hasSameColumns2(a,b);
        if (eq && p!=null) {
            eq = hasSameColumns2(p,a);
        }
        comp.has_same_columns = eq;
        comp.has_same_columns_known = true;
        return true;
    }

    private function hasSameColumns2(a : Table, b : Table) : Bool {
        if (a.width!=b.width) {
            return false;
        }
        if (a.height==0 || b.height==0) {
            return true;
        }

        // check for a blatant header - should only do this
        // for meta-data free tables, that may have embedded headers
        var av : View = a.getCellView();
        for (i in 0...a.width) {
            for (j in (i+1)...a.width) {
                if (av.equals(a.getCell(i,0),a.getCell(j,0))) {
                    return false;
                }
            }
            if (!av.equals(a.getCell(i,0),b.getCell(i,0))) {
                return false;
            }
        }

        return true;
    }

    private function testIsEqual() : Bool {
        var p : Table = comp.p;
        var a : Table = comp.a;
        var b : Table = comp.b;
        comp.getMeta();
        var nested = false;
        if (comp.p_meta!=null) if (comp.p_meta.isNested()) nested = true;
        if (comp.a_meta!=null) if (comp.a_meta.isNested()) nested = true;
        if (comp.b_meta!=null) if (comp.b_meta.isNested()) nested = true;
        if (nested) {
            // when nesting, we want to reach a smarter part of the code.
            comp.is_equal = false;
            comp.is_equal_known = true;
            return true;
        }
        var eq : Bool = isEqual2(a,b);
        if (eq && p!=null) {
            eq = isEqual2(p,a);
        }
        comp.is_equal = eq;
        comp.is_equal_known = true;
        return true;
    }
    
    private function isEqual2(a : Table, b : Table) : Bool {
        if (a.width!=b.width || a.height!=b.height) {
            return false;
        }
        var av : View = a.getCellView();
        for (i in 0...a.height) {
            for (j in 0...a.width) {
                if (!av.equals(a.getCell(j,i),b.getCell(j,i))) {
                    return false;
                }
            }
        }
        return true;
    }

    private function compareCore() : Bool {
        if (comp.completed) return false;
        if (!comp.is_equal_known) {
            return testIsEqual();
        }
        if (!comp.has_same_columns_known) {
            return testHasSameColumns();
        }
        comp.completed = true;
        return false;
    }

    /**
     *
     * During a comparison, we generate a set of indexes that help
     * relate the tables to each other.  Normally these will be
     * discarded as soon as possible in order to save memory.
     * If you'd like the indexes kept, call this method.
     *
     */
    public function storeIndexes() : Void {
        indexes = new Array<IndexPair>();
    }

    /**
     *
     * Access the indexes generated during the comparison.
     * The `storeIndexes()` method must be called before the
     * comparison.
     *
     * @return the indexes generated during the comparison after
     * the `storeIndexes()` method was called, or null if it
     * was never called.
     *
     */
    public function getIndexes() : Array<IndexPair> {
        return indexes;
    }

    private function useSql() : Bool {
        if (comp.compare_flags == null) return false;
        comp.getMeta();
        var sql = true;
        if (comp.p_meta!=null) if (!comp.p_meta.isSql()) sql = false;
        if (comp.a_meta!=null) if (!comp.a_meta.isSql()) sql = false;
        if (comp.b_meta!=null) if (!comp.b_meta.isSql()) sql = false;
        if (comp.p!=null && comp.p_meta==null) sql = false;
        if (comp.a!=null && comp.a_meta==null) sql = false;
        if (comp.b!=null && comp.b_meta==null) sql = false;
        return sql;
    }
}
