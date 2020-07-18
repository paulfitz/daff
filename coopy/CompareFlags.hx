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
     * turn on this flag, and turn off never_show_order.
     *
     */
    public var always_show_order : Bool;

    /**
     *
     * Diffs for tables where row/column order has been permuted may include
     * an extra row/column specifying the changes in row numbers.
     * If you'd like to be sure that that row/column is *never*
     * included, turn on this flag, and turn off always_show_order.
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

    /**
     *
     * List of tables to process.  Used when reading from a source
     * with multiple tables.  Defaults to null, meaning all tables.
     *
     */
    public var tables : Array<String>;

    /**
     *
     * Should cells in diff output contain nested content?
     * This is the difference between getting eg the string 
     * "version1->version2" and a hash {before: "version1", after: "version2"}.
     * Defaults to false.
     *
     */
    public var allow_nested_cells : Bool;

    /**
     *
     * List of warnings generated during a comparison.
     *
     */
    public var warnings : Array<String>;

    /**
     *
     * Strategy to use when making comparisons.  Valid values are "hash" and "sql".
     * The latter is only useful for SQL sources.  Leave null for a sensible default.
     *
     */
    public var diff_strategy : String;

    /**
     *
     * Strategy to use when padding columns.  Valid values are "smart", "dense",
     * and "sparse".  Leave null for a sensible default.
     *
     */
    public var padding_strategy : String;

    /**
     *
     * Show changes in column properties, not just data, if available.
     * Defaults to true.
     *
     */
    public var show_meta : Bool;

    /**
     *
     * Show all column properties, if available, even if unchanged.
     * Defaults to false.
     *
     */
    public var show_unchanged_meta : Bool;


    /**
     *
     * Set a common ancestor for use in comparison.  Defaults to null
     * (no known common ancestor).
     *
     */
    public var parent : Table;

    /**
     *
     * Should column numbers, if present, be rendered spreadsheet-style
     * as A,B,C,...,AA,BB,CC?
     * Defaults to true.
     *
     */
    public var count_like_a_spreadsheet : Bool;

    /**
     *
     * Should whitespace be omitted from comparisons.  Defaults to false.
     *
     */
    public var ignore_whitespace : Bool;

    /**
     *
     * Should case be omitted from comparisons.  Defaults to false.
     *
     */
    public var ignore_case : Bool;

    /**
     *
     * If set to a positive number, then cells that looks like floating point
     * numbers are treated as equal if they are within epsilon of each other.
     * This option does NOT affect the alignment of rows, so if a floating point
     * number is part of your table's primary key, this option will not help.
     * Defaults to a negative number (so it is disabled).
     *
     */
    public var ignore_epsilon : Float;

    /**
     *
     * Format to use for terminal output.  "plain" for plain text,
     * "ansi", for ansi color codes, null to autodetect.  Defaults to
     * autodetect.
     *
     */
    public var terminal_format : String;

    /**
     *
     * Choose whether we can use utf8 characters for describing diff
     * (specifically long arrow).  Defaults to true.
     *
     */
    public var use_glyphs : Bool;

    /**
     * Choose whether html elements should be neutralized or passed through,
     * in html contexts.
     *
     */
    public var quote_html : Bool;

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
        allow_nested_cells = false;
        warnings = null;
        diff_strategy = null;
        show_meta = true;
        show_unchanged_meta = false;
        tables = null;
        parent = null;
        count_like_a_spreadsheet = true;
        ignore_whitespace = false;
        ignore_case = false;
        ignore_epsilon = -1;
        terminal_format = null;
        use_glyphs = true;
        quote_html = true;
    }

    /**
     *
     * Filter for particular kinds of changes.
     * @param act set this to "update", "insert", "delete", or "column".
     * @param allow set this to true to allow this kind, or false to
     * deny it.
     * @return true if the kind of change was recognized.
     *
     */
    public function filter(act: String, allow: Bool) : Bool {
        if (acts==null) {
            acts = new Map<String,Bool>();
            acts.set("update",!allow);
            acts.set("insert",!allow);
            acts.set("delete",!allow);
            acts.set("column",!allow);
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
        return acts.exists("update") && acts.get("update");
    }

    /**
     *
     * @return true if inserts are allowed by the current filters.
     *
     */
    public function allowInsert() : Bool {
        if (acts==null) return true;
        return acts.exists("insert") && acts.get("insert");
    }

    /**
     *
     * @return true if deletions are allowed by the current filters.
     *
     */
    public function allowDelete() : Bool {
        if (acts==null) return true;
        return acts.exists("delete") && acts.get("delete");
    }

    /**
     *
     * @return true if column additions/deletions are allowed by the current filters.
     *
     */
    public function allowColumn() : Bool {
        if (acts==null) return true;
        return acts.exists("column") && acts.get("column");
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
     * Add a table to compare.  Fine to call multiple times,
     * although multiple tables won't do anything sensible
     * yet at the time of writing.
     *
     * @param table the name of a table to consider
     *
     */
    public function ignoreColumn(column: String) : Void {
        if (columns_to_ignore==null) columns_to_ignore = new Array<String>();
        columns_to_ignore.push(column);
    }

    public function addTable(table: String) : Void {
        if (tables==null) tables = new Array<String>();
        tables.push(table);
    }

    /**
     *
     * Add a warning. Used by daff to pass non-critical information
     * to the developer without disrupting operations.
     *
     * @param warn the warning text to record
     *
     */
    public function addWarning(warn: String) : Void {
        if (warnings==null) warnings = new Array<String>();
        warnings.push(warn);
    }

    /**
     *
     * @return any warnings generated during an operation.
     *
     */
    public function getWarning() : String {
        return warnings.join("\n");
    }

    /**
     *
     * Primary key and table names may be specified as "local:remote" or "parent:local:remote"
     * when they should be different for the local, remote, and parent sources.  This 
     * method returns the appropriate part of a name given a role of local, remote, or parent.
     *
     */
    public function getNameByRole(name: String, role: String): String {
        var parts = name.split(":");
        if (parts.length <= 1) { return name; }
        if (role == 'parent') {
            return parts[0];
        }

        if (role == 'local') {
            return parts[parts.length - 2];
        }
        return parts[parts.length - 1];
    }

    /**
     *
     * If we need a single name for a table/column, we use the local name.
     *
     */
    public function getCanonicalName(name: String): String {
        return getNameByRole(name, 'local');
    }

    /**
     *
     * Returns primary key for 'local', 'remote', and 'parent' sources.
     *
     */
    public function getIdsByRole(role: String): Array<String> {
        var result = new Array<String>();
        if (ids==null) {
            return result;
        }
        for (name in ids) {
            result.push(getNameByRole(name, role));
        }
        return result;
    }
}

