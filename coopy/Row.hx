// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * A trivial interface for indexable sources.
 *
 */
interface Row {
    /**
     *
     * Get the content in a given column.
     * 
     * @param c the column to look in
     * @return the content of column `c`
     *
     */
    function getRowString(c: Int) : String;

    /**
     *
     * @return true if row is header row (or before)
     *
     */
    function isPreamble() : Bool;
}
