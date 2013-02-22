// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

class Unit {
    public var l : Int;
    public var r : Int;
    public var p : Int;

    public function new(l: Int, r: Int, p: Int = -2) : Void {
        this.l = l;
        this.r = r;
        this.p = p;
    }

    public function lp() : Int {
        return (p==-2) ? l : p;
    } 
    

    public static function describe(i: Int) : String {
        return (i>=0) ? ("" + i) : "-";
    }

    public function toString() : String {
        if (p>=-1) return describe(p) + "|" + describe(l) + ":" + describe(r);
        return describe(l) + ":" + describe(r);
    }
}
