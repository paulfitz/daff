// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class Comparison {
    public var a: Table;
    public var b: Table;

    public var completed : Bool;
    public var run_to_completion : Bool;

    public var equal : Bool;
    public var equal_known : Bool;

    public function new() {
        completed = false;
        run_to_completion = true;
        equal_known = false;
        equal = false;
    }
}

