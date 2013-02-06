// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class Comparison {
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

    static public function compareTables(ct: CompareTable, t1: Table, t2: Table) : Comparison {
        var comp = new Comparison();
        comp.a = t1;
        comp.b = t2;
        ct.compare(comp);
        return comp;
    }

    static public function compareTables3(ct: CompareTable, t1: Table, t2: Table, t3: Table) : Comparison {
        var comp = new Comparison();
        comp.p = t1;
        comp.a = t2;
        comp.b = t3;
        ct.compare(comp);
        return comp;
    }
}
