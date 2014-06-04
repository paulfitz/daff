// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class CompareFlags {
    // Should we treat the data as ordered?
    public var ordered : Bool;

    // Should we show unchanged rows in diffs?
    public var show_unchanged : Bool;

    // What is the minimum number of rows around a changed row we should show?
    public var unchanged_context : Int;

    // Should we always decorate the diff with numerical indexes showing order?
    public var always_show_order : Bool;

    // Should we never decorate the diff with numerical indexes?
    public var never_show_order : Bool;

    // Should we show unchanged columns in diffs?
    // (note that index/key columns needed to identify rows will be shown
    // even if we turn this flag off)
    public var show_unchanged_columns : Bool;

    // What is the minimum number of columns around a changed
    // column that we should show?
    public var unchanged_column_context : Int;

    // Should we always give a table header in diffs?
    public var always_show_header : Bool;

    // Optional filters for actions, set any of:
    //   "update", "insert", "delete"
    // to true to accept just those actions.
    public var acts : Map<String, Bool>;

    public function new() {
        ordered = true;
        show_unchanged = false;
        unchanged_context = 1;
        always_show_order = false;
        never_show_order = true;
        show_unchanged_columns = false;
        unchanged_column_context = 1;
        always_show_header = true;
        acts = null;
    }

    public function allowUpdate() : Bool {
        if (acts==null) return true;
        return acts.exists("update");
    }

    public function allowInsert() : Bool {
        if (acts==null) return true;
        return acts.exists("insert");
    }

    public function allowDelete() : Bool {
        if (acts==null) return true;
        return acts.exists("delete");
    }
}

