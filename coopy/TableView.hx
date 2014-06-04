// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class TableView implements View {
    public function new() : Void {
    }

    public function toString(d: Dynamic) : String {
        return "" + d;
    }
    
    public function getBag(d: Dynamic) : Bag {
    	return null;
    }

    public function getTable(d: Dynamic) : Table {
        var table : Table = cast d;
        return table;
    }

    public function hasStructure(d: Dynamic) : Bool {
        return true;
    }

    public function equals(d1: Dynamic, d2: Dynamic) : Bool {
        trace("TableView.equals called");
        return false;
    }

    public function toDatum(str: Null<String>) : Dynamic {
        return new SimpleCell(str);
    }    
}

