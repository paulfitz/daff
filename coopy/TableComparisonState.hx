// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class TableComparisonState {
    public var p: Table;
    public var a: Table;
    public var b: Table;

    public var completed : Bool;
    public var run_to_completion : Bool;

    // Are tables trivially equal?
    public var is_equal : Bool;
    public var is_equal_known : Bool;

    // Do tables have blatantly same set of columns?
    public var has_same_columns : Bool;
    public var has_same_columns_known : Bool;

    public function new() : Void {
        reset();
    }

    public function reset() : Void {
        completed = false;
        run_to_completion = true;
        is_equal_known = false;
        is_equal = false;
        has_same_columns = false;
        has_same_columns_known = false;
    }
}
