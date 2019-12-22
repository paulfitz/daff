// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Everything daff needs to know about a table.  This interface
 * gets implemented natively on each language/platform daff supports,
 * so that we don't waste time making copies of tables from one format
 * to another.
 *
 */
interface Table {
    /**
     *
     * The number of rows in the table.  Read-only.  Implemented as
     * a call to `get_height()`.
     *
     */
    var height(get,never) : Int; // Read-only height property

    /**
     *
     * The number of columns in the table.  Read-only.  Implemented as
     * a call to `get_width()`.
     *
     */
    var width(get,never) : Int;   // Read-only width property

    /**
     *
     * Read a cell
     *
     * @param x the *column* to read from
     * @param y the *row* to read from
     * @return the content of the cell at row y and column x
     *
     */
    function getCell(x: Int, y: Int) : Dynamic;

    /**
     *
     * Write to a cell
     *
     * @param x the *column* to write to
     * @param y the *row* to write to
     * @param c the value to write
     *
     */
    function setCell(x: Int, y: Int, c : Dynamic) : Void;

    /**
     *
     * Get an interface for interpreting cell contents (e.g.
     * converting to a string).  We never call any methods
     * directly on a cell, since we've no idea what they
     * are.  To learn about the contents of a cell, we pass
     * it to methods of a `View`.
     *
     * @return a `View` interface for interpreting cell contents
     *
     */
    function getCellView() : View;

    /**
     *
     * Check if a table can be resized.
     *
     * @return true if the table can be resized
     *
     */
    function isResizable() : Bool;

    /**
     *
     * Resize a table, if possible, preserving existing contents that fit.
     * Any newly created cells should be `null`.
     *
     * @param w desired number of columns
     * @param h desired number of rows
     * @return true if the table was successfully resized
     *
     */
    function resize(w: Int, h: Int) : Bool;

    /**
     *
     * Clear the table if possible, leaving it with zero rows and columns.
     *
     */
    function clear() : Void;

    /**
     *
     * Insert, delete, and/or shuffle rows. We bundle all these operations
     * together since things can get creakingly slow otherwise.
     *
     * @param fate an array specifying, for each existing row, where that 
     * row should be now placed (-1 means "delete").
     * @param hfate the total number of rows after the operation. Any
     * rows that did not receive an existing row should be initialized
     * as a row of empty cells (nulls).
     * @return true on success
     *
     */
    function insertOrDeleteRows(fate: Array<Int>, hfate: Int) : Bool;

    /**
     *
     * Insert, delete, and/or shuffle columns. We bundle all these operations
     * together since things can get creakingly slow otherwise.
     *
     * @param fate an array specifying, for each existing column, where that 
     * column should be now placed (-1 means "delete").
     * @param hfate the total number of columns after the operation. Any
     * columns that did not receive an existing column should be initialized
     * as a column of empty cells (nulls).
     * @return true on success
     *
     */
    function insertOrDeleteColumns(fate: Array<Int>, wfate: Int) : Bool;

    /**
     *
     * Remove empty final rows or final columns. This method is not in
     * fact used by the daff library.
     *
     * @return true on success
     *
     */
    function trimBlank() : Bool;

    /**
     *
     * Get the width of the table.  Sorry for the inconsistent 
     * capitalization, it is due to a confusion I had over haxe
     * setter/getters.
     *
     * @return the number of columns in the table
     *
     */
    function get_width() : Int;

    /**
     *
     * Get the height of the table.  Sorry for the inconsistent 
     * capitalization, it is due to a confusion I had over haxe
     * setter/getters.
     *
     * @return the number of rows in the table
     *
     */
    function get_height() : Int;

    /**
     *
     * Get the underlying data object backing the table, if possible.
     * This is platform specific.  The daff library never uses this
     * method.
     *
     * @return an object of some kind - enjoy!
     *
     */
    function getData() : Dynamic;

    /**
     *
     * @return a copy of the table.
     *
     */
    function clone() : Table;

    /**
     *
     * @return an empty table of the same type, if possible, or null if not possible.
     *
     */
    function create() : Table;

    /**
     *
     * @return a interface to the columns of this table, or null
     * if no interface is available.
     *
     */
    function getMeta() : Meta;
}
