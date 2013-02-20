// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

class Ordering {
    private var order : Array<Unit>;
    private var ignore_parent : Bool;

    public function new() : Void {
        order = new Array<Unit>();
        ignore_parent = false;
    }

    public function add(l: Int, r: Int, p: Int = -2) : Void {
        if (ignore_parent) p = -2;
        order.push(new Unit(l,r,p));
    }

    public function getList() : Array<Unit> {
        return order;
    }

    public function toString() : String {
        var txt : String = "";
        for (i in 0...order.length) {
            if (i>0) txt += ", ";
            txt += order[i];
        }
        return txt;
    }

    public function ignoreParent() : Void {
        ignore_parent = true;
    }
}
