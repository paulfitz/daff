// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class BagView implements View {
    public function new() : Void {
    }

    public function toString(d: Datum) : String {
        return "" + d;
    }
    
    public function getBag(d: Datum) : Bag {
        var bag : Bag = cast d;
        return bag;
    }

    public function getTable(d: Datum) : Table {
        return null;
    }

    public function hasStructure(d: Datum) : Bool {
        return true;
    }

    public function equals(d1: Datum, d2: Datum) : Bool {
        trace("BagView.equals called");
        return false;
    }
}

