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

    private function align() : Alignment {
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
        // just playing with alignment
        // using an exceedingly exceedingly excessively slow algorithm first
        // for fast stuff, see coopy (C++ version)

        if (!comp.has_same_columns) return;

        var a : Table = comp.a;
        var b : Table = comp.b;
        align.range(a.height,b.height);
        
        var w : Int = a.width;
        var ha : Int = a.height;
        var hb : Int = b.height;

        var av : View = a.getCellView();
        for (i in 0...ha) {
            //if (align.a2b(i)!=null) continue;
            for (j in 0...hb) {
                //if (align.b2a(j)!=null) continue;

                // comparing everything with everything - already slow.
                // and we haven't even started

                var match : Float = 0;
                var mt : MatchTypes = new MatchTypes(comp,align);
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
        var a : Table = comp.a;
        var b : Table = comp.b;
        if (a.width!=b.width) {
            comp.has_same_columns = false;
            comp.has_same_columns_known = true;
            return true;
        }
        if (a.height==0 || b.height==0) {
            comp.has_same_columns = true;
            comp.has_same_columns_known = true;
            return true;
        }
        // check for a blatant header - should only do this
        // for meta-data free tables, that may have embedded headers
        var av : View = a.getCellView();
        for (i in 0...a.width) {
            for (j in (i+1)...a.width) {
                if (av.equals(a.getCell(i,0),a.getCell(j,0))) {
                    comp.has_same_columns = false;
                    comp.has_same_columns_known = true;
                    return true;
                }
            }
            if (!av.equals(a.getCell(i,0),b.getCell(i,0))) {
                comp.has_same_columns = false;
                comp.has_same_columns_known = true;
                return true;
            }
        }
        comp.has_same_columns = true;
        comp.has_same_columns_known = true;
        return true;
    }
    
    private function testIsEqual() : Bool {
        var a : Table = comp.a;
        var b : Table = comp.b;
        if (a.width!=b.width || a.height!=b.height) {
            comp.is_equal = false;
            comp.is_equal_known = true;
            return true;
        }
        var av : View = a.getCellView();
        for (i in 0...a.height) {
            for (j in 0...a.width) {
                if (!av.equals(a.getCell(j,i),b.getCell(j,i))) {
                    comp.is_equal = false;
                    comp.is_equal_known = true;
                    return true;
                }
            }
        }
        comp.is_equal = true;
        comp.is_equal_known = true;
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
