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
}
