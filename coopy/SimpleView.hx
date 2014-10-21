// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class SimpleView implements View {
    public function new() : Void {
    }

    public function toString(d: Dynamic) : String {
        if (d==null) return null;
        return "" + d;
    }
    
    public function getBag(d: Dynamic) : Bag {
        return null;
    }

    public function getTable(d: Dynamic) : Table {
        return null;
    }

    public function hasStructure(d: Dynamic) : Bool {
        return false;
    }

    public function equals(d1: Dynamic, d2: Dynamic) : Bool {
        //trace("Comparing " + d1 + " and " + d2 + " -- " +  (("" + d1) == ("" + d2)));
        if (d1==null && d2==null) return true;
        if (d1==null && (""+d2)=="") return true;
        if ((""+d1)=="" && d2==null) return true;
        return ("" + d1) == ("" + d2);
    }

    public function toDatum(x: Dynamic) : Dynamic {
#if cpp
        return new SimpleCell(x);
#else
        return x;
#end
    }
}

