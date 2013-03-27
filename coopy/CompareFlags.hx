// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class CompareFlags {
    public var show_unchanged : Bool;
    public var always_show_header : Bool;

    public function new() {
        show_unchanged = false;
        always_show_header = false;
    }
}

