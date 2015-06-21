// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Interpretation of a cell in a diff, produced by `DiffRender.renderCell`.
 * Useful for custom views of a diff.
 *
 */
@:expose
class CellInfo {
    /**
     *
     * The cell value "as is".
     *
     */
    public var raw : Dynamic;

    /**
     *
     * The cell value in text form.
     *
     */
    public var value : String;

    /**
     *
     * The cell value in text form, with some special characters rendered
     * prettier (e.g. `->` is converted to an appropriate glyph, and
     * certain spaces in diffs are converted to a visible space glyph)
     *
     */
    public var pretty_value : String;

    /**
     *
     * The type of activity going on in the cell: "move", "add", "remove",
     * "modify", "conflict", "header", "spec"
     *
     *  + "move" means a row/column that has moved
     *  + "add" means a row/column that has been inserted
     *  + "remove" means a row/column that has been deleted
     *  + "modify" means a cell that has been changed
     *  + "conflict" means a cell that has been changed in a conflicting way
     *  + "header" means part of a row giving column names
     *  + "spec" means part of a row specifying column changes
     *
     */
    public var category : String;

    /**
     *
     * The type of activity going on in the cell, based only on
     * knowledge of what row it is in.
     *
     */
    public var category_given_tr : String;
    
    /**
     *
     * Any separator found in the cell.
     *
     */
    public var separator : String;

    /**
     *
     * Any separator found in the cell, made pretty using a glyph.
     *
     */
    public var pretty_separator : String;

    /**
     *
     * True if there is an update in the cell, the cell contains
     * two values, an `lvalue` (before) and an `rvalue` (after)
     *
     */
    public var updated : Bool;

    /**
     *
     * True if there is a conflicting update in the cell, the cell 
     * contains three values, a `pvalue` (common ancestor/parent), 
     * an `lvalue` (local change) and an `rvalue` (remote change)
     *
     */
    public var conflicted : Bool;

    /**
     *
     * Parent cell value if applicable.
     *
     */
    public var pvalue : String;

    /**
     *
     * Local/reference cell value if applicable.
     *
     */
    public var lvalue : String;

    /**
     *
     * Remote/changed cell value if applicable.
     *
     */
    public var rvalue : String;

    /**
     *
     * If this is a change in a property of the table rather than
     * the data in the table itself, this field names that property.
     *
     */
    public var meta : String;

    public function new() : Void {}

    /**
     *
     * Give a summary of the information contained for debugging purposes.
     *
     */
    public function toString() : String {
        if (!updated) return value;
        if (!conflicted) return lvalue + "::" + rvalue;
        return pvalue + "||" + lvalue + "::" + rvalue;
    }
}
