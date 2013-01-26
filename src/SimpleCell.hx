// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class SimpleCell implements Datum {
    private var datum : Dynamic;

    public var bag : Bag;

    public function new(x: Dynamic) {
        bag = null;
        datum = x;
    }
    public function toString() : String {
        return datum;
    }
}
