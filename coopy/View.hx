// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Interface for interpreting cell contents. In most cases the implementation
 * will be entirely trivial.
 *
 */
interface View {
    /**
     *
     * Convert a cell to text form.
     * @param d a cell
     * @return the cell in text form
     *
     */
    function toString(d: Dynamic) : String;

    /**
     *
     * Compare two cells.
     * @param d1 the first cell
     * @param d2 the second cell
     * @return true if the cells are equal
     *
     */
    function equals(d1: Dynamic, d2: Dynamic) : Bool;

    /**
     *
     * Convert a string to a cell.
     * @param str the string
     * @return the string converted to a cell
     *
     */
    function toDatum(str: String) : Dynamic;
}
