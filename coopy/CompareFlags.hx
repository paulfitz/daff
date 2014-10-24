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

    // List of columns that make up a primary key, if known - otherwise
    // heuristics are used to find a decent key (or a set of decent keys).
    public var ids : Array<String>;

    // List of columns to ignore, changes related to these columns
    // should not count in diffs.
    public var columns_to_ignore : Array<String>;

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
        ids = null;
        columns_to_ignore = null;
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

    public function getIgnoredColumns() : Map<String,Bool> {
        if (columns_to_ignore==null) return null;
        var ignore = new Map<String,Bool>();
        for (i in 0...columns_to_ignore.length) {
            ignore.set(columns_to_ignore[i],true);
        }
        return ignore;
    }

    // Add a column to the primary key.  If this is never called,
    // then we will muddle along without it.  Fine to call multiple
    // times to set up a multi-column primary key.
    public function addPrimaryKey(column: String) : Void {
        if (ids == null) ids = new Array<String>();
        ids.push(column);
    }

    // Add a column to ignore in all calculations.  Fine to call
    // multiple times.
    public function ignoreColumn(column: String) : Void {
        if (columns_to_ignore==null) columns_to_ignore = new Array<String>();
        columns_to_ignore.push(column);
    }
}

