// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class CompareTable {
    private var comp: TableComparisonState;

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

        var indexes : Map<String,IndexPair> = new Map<String,IndexPair>();

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
    }

    private function alignColumns(align: Alignment, a: Table, b: Table) : Void {
        align.range(a.width,b.width);
        align.tables(a,b);
        align.setRowlike(false);

        var wmin : Int = a.width;
        if (b.width<a.width) wmin = b.width;

        var av : View = a.getCellView();

        var has_header : Bool = true;
        var submatch : Bool = true;
        var names : Map<String,Int> = new Map<String,Int>();

        for (i in 0...a.width) {
            var key : String = av.toString(a.getCell(i,0));
            if (names.exists(key)) {
                has_header = false;
                break;
            }
            names.set(key,-1);
        }
        names = new Map<String,Int>();
        if (has_header) {
            for (i in 0...b.width) {
                var key : String = av.toString(b.getCell(i,0));
                if (names.exists(key)) {
                    has_header = false;
                    break;
                }
                names.set(key,i);
            }
        }

        if (has_header) {
            for (i in 0...wmin) {
                if (!av.equals(a.getCell(i,0),b.getCell(i,0))) {
                    submatch = false;
                    break;
                }
            }
            if (submatch) {
                for (i in 0...wmin) {
                    align.link(i,i);
                }
                return;
            }
        }

        if (has_header) {
            for (i in 0...a.width) {
                var key : String = av.toString(a.getCell(i,0));
                var v : Null<Int> = names.get(key);
                if (v!=null) {
                    align.link(i,v);
                }
            }
        }
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
}
