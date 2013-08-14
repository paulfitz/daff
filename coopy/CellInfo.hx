// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class CellInfo {
    public var value : String;
    public var pretty_value : String;
    public var category : String;
    public var category_given_tr : String;
    
    // relevant to updates, conflicts
    public var separator : String;
    public var updated : Bool;
    public var conflicted : Bool;
    public var pvalue : String;
    public var lvalue : String;
    public var rvalue : String;

    public function new() : Void {}

    public function toString() : String {
        if (!updated) return value;
        if (!conflicted) return lvalue + "::" + rvalue;
        return pvalue + "||" + lvalue + "::" + rvalue;
    }
}
