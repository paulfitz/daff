// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * An iterator for rows of a table.
 *
 */
interface RowStream {
    function fetchColumns() : Array<String>;
    function fetchRow() : Map<String, Dynamic>;
}
