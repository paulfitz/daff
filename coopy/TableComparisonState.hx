// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * State of a comparison between tables.
 *
 */
@:expose
class TableComparisonState {
    /**
     *
     * The common ancestor ("parent") table - null if none.
     *
     */
    public var p: Table;

    /**
     *
     * The reference "local" table.
     *
     */
    public var a: Table;

    /**
     *
     * The modified "remote" table.
     *
     */
    public var b: Table;

    /**
     *
     * Has the comparison run to completion?
     *
     */
    public var completed : Bool;

    /**
     *
     * Should the comparison run to completion?
     *
     */
    public var run_to_completion : Bool;

    /**
     *
     * Are the tables identical?
     *
     */
    public var is_equal : Bool;

    /**
     *
     * Has `is_equal` been determined yet?
     *
     */
    public var is_equal_known : Bool;

    /**
     *
     * Do tables have blatantly the same set of columns?
     *
     */
    public var has_same_columns : Bool;

    /**
     *
     * Has `has_same_columns` been determined yet?
     *
     */
    public var has_same_columns_known : Bool;

    /**
     *
     * The flags that should be used during comparison.
     *
     */
    public var compare_flags : CompareFlags;

    public var p_meta : Meta;
    public var a_meta : Meta;
    public var b_meta : Meta;

    public var alignment : Alignment;
    public var children : Map<String,TableComparisonState>;
    public var child_order : Array<String>;

    public function new() : Void {
        reset();
    }

    /**
     *
     * Set the comparison back to a default state, as if no computation
     * has been done.
     *
     */
    public function reset() : Void {
        completed = false;
        run_to_completion = true;
        is_equal_known = false;
        is_equal = false;
        has_same_columns = false;
        has_same_columns_known = false;
        compare_flags = null;
        alignment = null;
        children = null;
        child_order = null;
    }

    public function getMeta() : Void {
        if (p!=null && p_meta==null) p_meta = p.getMeta();
        if (a!=null && a_meta==null) a_meta = a.getMeta();
        if (b!=null && b_meta==null) b_meta = b.getMeta();
    }
}
