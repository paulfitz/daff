// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Describe and manipulate columns of a table.
 *
 */
interface Meta {
    /**
     *
     * Change the columns of a table.
     *
     * @param columns an ordered list of columns and the changes 
     * to apply.
     *
     * @return true on success.
     *
     */
    function alterColumns(columns : Array<ColumnChange>) : Bool;

    /**
     *
     * @return A table describing the columns of a table, if available.
     * If a table is returned, it should have the same number 
     * of columns as the original, plus on extra
     * initial column. Its header row should be the same
     * as the original, with "@" in the extra column.
     * Subsequent rows may have an arbitrary tag in the first
     * column, followed by values to be associated with that tag
     * for each column.
     *
     */
    function asTable() : Table;

    /**
     *
     * @return a copy of this object. Ok not to implement.
     *
     */
    function clone(table: Table = null) : Meta;
}
