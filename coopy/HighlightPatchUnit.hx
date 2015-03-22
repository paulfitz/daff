// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
@:noDoc
class HighlightPatchUnit {
    public var add : Bool;
    public var rem : Bool;
    public var update : Bool;

    public var code : String;
    public var sourceRow : Int;  // row in original
    public var sourceRowOffset : Int;  // row in original
    public var sourcePrevRow : Int; // row before this in original
    public var sourceNextRow : Int; // row after this in original
    public var destRow : Int;    // row in output
    public var patchRow : Int;   // row in patch
    
    public function new() {
        add = false;
        rem = false;
        update = false;
        sourceRow = -1;
        sourceRowOffset = 0;
        sourcePrevRow = -1;
        sourceNextRow = -1;
        destRow = -1;
        patchRow = -1;
        code = "";
    }

    public function toString() : String {
        return "(" + code + " patch " + patchRow + " source " + sourcePrevRow + ":" + sourceRow + ":" + sourceNextRow + "+" + sourceRowOffset + " dest " + destRow + ")";
    }
}

