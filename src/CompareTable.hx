// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class CompareTable {
    public function new() {}

    public function compare(comp: Comparison) : Bool {
        var done : Bool = compareCore(comp);
        while ((!done) && comp.run_to_completion) {
            done = compareCore(comp);
        }
        return done;
    }

    public function compareCore(comp: Comparison) : Bool {
        if (comp.completed) return true;
        if (comp.equal_known == false) {
            var a : Table = comp.a;
            var b : Table = comp.b;
            if (a.width!=b.width || a.height!=b.height) {
                comp.equal = false;
                comp.equal_known = true;
                comp.completed = true;
                return false;
            }
            var av : View = a.getCellView();
            for (i in 0...a.height) {
                for (j in 0...a.width) {
                    if (!av.equals(a.getCell(j,i),b.getCell(j,i))) {
                        comp.equal = false;
                        comp.equal_known = true;
                        comp.completed = true;
                        return false;
                    }
                }
            }
            comp.equal = true;
            comp.equal_known = true;
        }
        comp.completed = true;
        return true;
    }
}
