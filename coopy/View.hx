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

    /**
     *
     * Create a native hash/map object.
     * @return the newly created hash/map, or null if not available
     *
     */
    function makeHash() : Dynamic;

    /**
     *
     * Add something to a native hash/map object.
     * @param h the hash/map
     * @param str the key to use
     * @param d the value to use
     *
     */
    function hashSet(h: Dynamic, str: String, d: Dynamic) : Void;

    /**
     *
     * @param h possible hash/map to check
     * @return true if h is a hash/map
     *
     */
    function isHash(h: Dynamic) : Bool;

    /**
     *
     * Check if a hash/map contains a given key
     *
     * @param h hash/map to check
     * @param str key to check
     * @return true if hash/map contains the given key
     *
     */
    function hashExists(h: Dynamic, str: String) : Bool;

    /**
     *
     * Check if a hash/map contains a given key
     *
     * @param h hash/map to check
     * @param str key to check
     * @return true if hash/map contains the given key
     *
     */
    function hashGet(h: Dynamic, str: String) : Dynamic;

    function isTable(t : Dynamic) : Bool;

    function getTable(t : Dynamic) : Table;

    function wrapTable(t : Table) : Dynamic;
}
