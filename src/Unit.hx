// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class Unit {
    public var l : Int;
    public var r : Int;
    
    public function new(l: Int, r: Int) : Void {
        this.l = l;
        this.r = r;
    }

    public static function describe(i: Int) : String {
        return (i>=0) ? ("" + i) : "-";
    }

    public function toString() : String {
        return describe(l) + ":" + describe(r);
    }
}
