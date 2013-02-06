// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class SimpleView implements View {
    public function new() : Void {
    }

    public function toString(d: Datum) : String {
        return "" + d;
    }
    
    public function getBag(d: Datum) : Bag {
        return null;
    }

    public function getTable(d: Datum) : Table {
        return null;
    }

    public function hasStructure(d: Datum) : Bool {
        return false;
    }

    public function equals(d1: Datum, d2: Datum) : Bool {
        //trace("Comparing " + d1 + " and " + d2 + " -- " +  (("" + d1) == ("" + d2)));
        if (d1==null && d2==null) return true;
        return ("" + d1) == ("" + d2);
    }
}

