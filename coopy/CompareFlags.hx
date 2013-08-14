// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class CompareFlags {
    public var always_show_header : Bool;
    public var show_unchanged : Bool;
    public var unchanged_context : Int;
    public var always_show_order : Bool;
    public var never_show_order : Bool;
    public var ordered : Bool;

    public function new() {
        always_show_header = true;
        show_unchanged = false;
        unchanged_context = 1;
        always_show_order = false;
        never_show_order = true;
        ordered = true;
    }
}

