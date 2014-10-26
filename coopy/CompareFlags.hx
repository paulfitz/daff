// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Flags that influence how tables are compared and how information
 * is presented.
 *
 */
@:expose
class CompareFlags {
    /**
     *
     * Is the order of rows and columns meaningful? Defaults to `true`.
     *
     */
    public var ordered : Bool;

    /**
     *
     * Should we show all rows in diffs?  We default to showing
     * just rows that have changes (and some context rows around
     * them, if row order is meaningful), but you can override
     * this here.
     *
     */
    public var show_unchanged : Bool;

    /**
     *
     * When showing context rows around a changed row, what
     * is the minimum number of such rows we should show?
     *
     */
    public var unchanged_context : Int;

    /**
     *
     * Diffs for tables where row/column order has been permuted may include
     * an extra row/column specifying the changes in row numbers.
     * If you'd like that extra row/column to always be included,
     * turn on this flag.
     *
     */
    public var always_show_order : Bool;

    /**
     *
     * Diffs for tables where row/column order has been permuted may include
     * an extra row/column specifying the changes in row numbers.
     * If you'd like to be sure that that row/column is *never*
     * included, turn on this flag.
     *
     */
    public var never_show_order : Bool;

    /**
     *
     * Should we show all columns in diffs?  We default to showing
     * just columns that have changes (and some context columns around
     * them, if column order is meaningful), but you can override
     * this here.  Irrespective of this flag, you can rely
     * on index/key columns needed to identify rows to be included
     * in the diff.
     *
     */
    public var show_unchanged_columns : Bool;

    /**
     *
     * When showing context columns around a changed column, what
     * is the minimum number of such columns we should show?
     *
     */
    public var unchanged_column_context : Int;

    /**
     *
     * Should we always give a table header in diffs? This defaults
     * to true, and - frankly - you should leave it at true for now.
     *
     */ 
    public var always_show_header : Bool;

    /**
     *
     * Optional filters for what kind of changes we want to show.
     * Please call `filter()`
     * to choose your filters, this variable will be made private soon.
     *
     */
    public var acts : Map<String, Bool>;

    /**
     * List of columns that make up a primary key, if known.
     * Otherwise heuristics are used to find a decent key
     * (or a set of decent keys). Please set via (multiple 
     * calls of) `addPrimaryKey()`.  This variable will be made private
     * soon.
     *
     */
    public var ids : Array<String>;

    /**
     *
     * List of columns to ignore in all calculations.  Changes
     * related to these columns should be discounted.  Please set 
     * via (multiple calls of) `ignoreColumn`.
     *
     */
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

    /**
     *
     * Filter for particular kinds of changes.
     * @param act set this to "update", "insert", or "delete"
     * @param allow set this to true to allow this kind, or false to
     * deny it.
     * @retrun true if the kind of change was recognized.
     *
     */
    public function filter(act: String, allow: Bool) : Bool {
        if (acts==null) {
            acts = new Map<String,Bool>();
            acts.set("update",!allow);
            acts.set("insert",!allow);
            acts.set("delete",!allow);
        }
        if (!acts.exists(act)) return false;
        acts.set(act,allow);
        return true;
    }

    /**
     *
     * @return true if updates are allowed by the current filters.
     *
     */
    public function allowUpdate() : Bool {
        if (acts==null) return true;
        return acts.exists("update");
    }

    /**
     *
     * @return true if inserts are allowed by the current filters.
     *
     */
    public function allowInsert() : Bool {
        if (acts==null) return true;
        return acts.exists("insert");
    }

    /**
     *
     * @return true if deletions are allowed by the current filters.
     *
     */
    public function allowDelete() : Bool {
        if (acts==null) return true;
        return acts.exists("delete");
    }

    /**
     *
     * @return the columns to ignore, as a map. For internal use.
     *
     */
    public function getIgnoredColumns() : Map<String,Bool> {
        if (columns_to_ignore==null) return null;
        var ignore = new Map<String,Bool>();
        for (i in 0...columns_to_ignore.length) {
            ignore.set(columns_to_ignore[i],true);
        }
        return ignore;
    }

    /**
     *
     * Add a column to the primary key.  If this is never called,
     * then we will muddle along without it.  Fine to call multiple
     * times to set up a multi-column primary key.
     *
     * @param column a name of a column to add to the primary key
     *
     */
    public function addPrimaryKey(column: String) : Void {
        if (ids == null) ids = new Array<String>();
        ids.push(column);
    }

    /**
     *
     * Add a column to ignore in all calculations.  Fine to call
     * multiple times.
     *
     * @param column a name of a column to ignore
     *
     */
    public function ignoreColumn(column: String) : Void {
        if (columns_to_ignore==null) columns_to_ignore = new Array<String>();
        columns_to_ignore.push(column);
    }
}

