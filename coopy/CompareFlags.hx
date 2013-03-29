// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class CompareFlags {
    public var always_show_header : Bool;
    public var show_unchanged : Bool;
    public var unchanged_context : Int;

    public function new() {
        always_show_header = true;
        show_unchanged = false;
        unchanged_context = 1;
    }
}

