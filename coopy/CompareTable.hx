// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class CompareTable {
    private var comp: TableComparisonState;
    private var indexes : Array<IndexPair>;

    public function new() {}

    public function attach(comp: TableComparisonState) : Bool {
        this.comp = comp;
        var more : Bool = compareCore();
        while (more && comp.run_to_completion) {
            more = compareCore();
        }
        return !more;
    }

    public function align() : Alignment {
        var alignment : Alignment = new Alignment();
        /*
        var count : Int = 0;
        do {
            count = alignment.count();
            alignCore(alignment);
        } while (false && alignment.count()>count);
        */
        alignCore(alignment);
        return alignment;
    }

    public function getComparisonState() : TableComparisonState {
        return comp;
    }

    private function alignCore(align: Alignment) : Void {
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
        var common_units : Array<Unit> = new Array<Unit>();
        for (unit in column_order.getList()) {
            if (unit.l>=0 && unit.r>=0 && unit.p!=-1) {
                common_units.push(unit);
            }
        }

        align.range(a.height,b.height);
        align.tables(a,b);
        align.setRowlike(true);
        
        var w : Int = a.width;
        var ha : Int = a.height;
        var hb : Int = b.height;

        var av : View = a.getCellView();

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
            var sorter = function(a,b) { if (a[1]<b[1]) return 1; if (a[1]>b[1]) return -1; return 0; }
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
        var pending_ct : Int = ha;
        
        for (k in 0...top) {
            if (k==0) continue;
            //var ct: Int = 0;
            //for (j in pending.keys()) ct++;
            //trace(ct);
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

            var index : IndexPair = new IndexPair();
            for (k in 0...active_columns.length) {
                var unit : Unit = common_units[active_columns[k]];
                index.addColumns(unit.l,unit.r);
            }
            index.indexTables(a,b);

            var h : Int = a.height;
            if (b.height>h) h = b.height;
            if (h<1) h = 1;
            var wide_top_freq : Int = index.getTopFreq();
            var ratio : Float = wide_top_freq;
            ratio /= (h+20); // "20" allows for low-data 
            if (ratio>=0.1) continue; // lousy no-good index, move on

            if (indexes!=null) {
                indexes.push(index);
            }

            var fixed : Array<Int> = new Array<Int>();
            for (j in pending.keys()) {
                var cross: CrossMatch = index.queryLocal(j);
                var spot_a : Int = cross.spot_a;
                var spot_b : Int = cross.spot_b;
                if (spot_a!=1 || spot_b!=1) continue;
                fixed.push(j);
                align.link(j,cross.item_b.lst[0]);
            }
            for (j in 0...fixed.length) {
                pending.remove(fixed[j]);
                pending_ct--;
            }
        }
        // we expect headers on row 0 - link them even if quite different.
        align.link(0,0);
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
            if (ra>=a.height) break;
            for (rb in 0...slop) {
                if (rb>=b.height) break;
                var ma : Map<String,Int> = new Map<String,Int>();
                var mb : Map<String,Int> = new Map<String,Int>();
                var ct : Int = 0;
                var uniques : Int = 0;
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
                uniques = 0;
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

                for (key in ma.keys()) {
                    var i0 : Int = ma.get(key);
                    var i1 : Null<Int> = mb.get(key);
                    if (i1>=0 && i0>=0) {
                        ct++;
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

        if (ma_best==null) return;
        for (key in ma_best.keys()) {
            var i0 : Int = ma_best.get(key);
            var i1 : Null<Int> = mb_best.get(key);
            if (i1>=0 && i0>=0) {
                align.link(i0,i1);
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

    public function storeIndexes() : Void {
        indexes = new Array<IndexPair>();
    }

    public function getIndexes() : Array<IndexPair> {
        return indexes;
    }
}
