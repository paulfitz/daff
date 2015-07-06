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
     * Add, remove, or update a row of the table.
     *
     * @param rc the change to make.
     *
     * @return true on success.
     *
     */
    function changeRow(rc: RowChange) : Bool;

    /**
     *
     * Apply flags to control future changes to table.
     *
     * @param flags the desired options.
     *
     * @return true on success.
     *
     */
    function applyFlags(flags: CompareFlags) : Bool;

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
     * Make a copy.  Deprecated.
     *
     * @return a copy of this object.
     *
     */
    function cloneMeta(table: Table = null) : Meta;

    /**
     *
     * @return true if the interface can make column-level changes.
     *
     */
    function useForColumnChanges() : Bool;

    /**
     *
     * @return true if the interface can make row-level changes.
     *
     */
    function useForRowChanges() : Bool;

    /**
     *
     * @return a streaming interface for rows.
     *
     */
    function getRowStream() : RowStream;


    /**
     *
     * @return true if the table may be nested (containing subtables).
     *
     */
    function isNested() : Bool;

    /**
     *
     * @return true if the table is best accessed via sql.
     *
     */
    function isSql() : Bool;

    /**
     *
     * @return a name for the table if it has one, otherwise null.
     *
     */
    function getName() : String;
}
