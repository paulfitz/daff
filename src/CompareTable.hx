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
