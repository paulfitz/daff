// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class Ordering {
    public var order : Array<Unit>;

    public function new() : Void {
        order = new Array<Unit>();
    }

    public function add(l: Int, r: Int) : Void {
        order.push(new Unit(l,r));
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
}
