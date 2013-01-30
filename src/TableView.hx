// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class TableView implements View {
    public function new() : Void {
    }

    public function toString(d: Datum) : String {
        return "" + d;
    }
    
    public function getBag(d: Datum) : Bag {
    	return null;
    }

    public function getTable(d: Datum) : Table {
        var table : Table = cast d;
        return table;
    }

    public function hasStructure(d: Datum) : Bool {
        return true;
    }

    public function equals(d1: Datum, d2: Datum) : Bool {
        trace("TableView.equals called");
        return false;
    }
}

