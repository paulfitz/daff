// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class HighlightPatchUnit {
    public var add : Bool;
    public var rem : Bool;
    public var pad : Bool;

    public var sourceRow : Int;  // row in original
    public var destRow : Int;    // row in output
    public var patchRow : Int;   // row in patch
    
    public function new() {
        add = false;
        rem = false;
        sourceRow = -1;
        destRow = -1;
        patchRow = -1;
    }

    public function toString() : String {
        return (add?"insert":(rem?"delete":"update")) + " " + sourceRow + ":" + destRow + " " + patchRow;
    }
}

