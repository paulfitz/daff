// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * The special case of tables with named columns and named rows may be an
 * interface to some underlying representation that is order-free.  In that
 * case the insert/delete/update interface can be simplified.
 *
 */
interface Meta {
    /**
     *
     * Pass in: fate of columns in order.  Column order under control, but not property order.
     * properties of columns indexed by new name
     *
     */
    function alterColumns(columns : Array<ColumnChange>) : Bool;

    function addColumn(key: String, vals: Map<String,Dynamic>, idx: Int = -1) : Bool;
    function removeColumn(key: String) : Bool;
    function renameColumn(prev: String, next: String) : Bool;
    function moveColumn(key: String, idx : Int) : Bool;
    function addRow(key: String, vals: Map<String,Dynamic>, idx : Int = -1) : Bool;
    function removeRow(key: String) : Bool;
    function renameRow(prev: String, next: String) : Bool;
    function moveRow(key: String, idx : Int) : Bool;
    function setCell(c: String, r: String, val: Dynamic) : Bool;

    /**
     *
     * If we can be edited in bulk as a table, it may be more
     * efficient to do so rather than serializing changes.
     *
     */
    function asTable() : Table;

    function canEditAsTable() : Bool;
}
