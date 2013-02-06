// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class CompareTable {
    private var comp: Comparison;

    public function new() {}

    public function compare(comp: Comparison) : Bool {
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

    private function alignCore(align: Alignment) : Void {
        if (comp.p==null) {
            alignCore2(align,comp.a,comp.b);
            return;
        }
        align.reference = new Alignment();
        alignCore2(align,comp.p,comp.b);
        alignCore2(align.reference,comp.p,comp.a);
    }

    private function alignCore2(align: Alignment,a: Table, b: Table) : Void {
        // just playing with alignment
        // using an exceedingly exceedingly excessively slow algorithm first
        // for fast stuff, see coopy (C++ version)

        if (!comp.has_same_columns) return;

        align.range(a.height,b.height);
        align.tables(a,b);
        
        var w : Int = a.width;
        var ha : Int = a.height;
        var hb : Int = b.height;

        var av : View = a.getCellView();

        var apending : IntHash<Int> = new IntHash<Int>();
        var bpending : IntHash<Int> = new IntHash<Int>();
        for (i in 0...ha) {
            apending.set(i,i);
        }
        for (i in 0...hb) {
            bpending.set(i,i);
        }

        var indexes : Hash<IndexPair> = new Hash<IndexPair>();
        for (i in 0...ha) {
            for (j in 0...hb) {
                // comparing everything with everything - already slow.
                // and we haven't even started

                var match : Float = 0;
                var mt : MatchTypes = new MatchTypes(comp,align,a,b,indexes);
                for (k in 0...w) {
                    var va : Datum = a.getCell(k,i);
                    var vb : Datum = b.getCell(k,j);
                    if (av.equals(va,vb)) {
                        mt.add(k,va);
                    }
                }
                // ok we know what columns our two rows match in -
                // now we go and do statistics on matches in those
                // rows (super slow!)

                if (mt.evaluate()) {
                    align.link(i,j);
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
