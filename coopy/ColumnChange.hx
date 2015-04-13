// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Represent a change to a single column.
 *
 */
@:expose
class ColumnChange {
    /**
     *
     * The original name of the column. If null, the column
     * is to be created.
     *
     */
    public var prevName : String;

    /**
     *
     * The new name of the column. If null, the column
     * is to be destroyed.
     *
     */
    public var name : String;

    /**
     *
     * A list of changes to properties of the column.
     *
     */
    public var props : Array<PropertyChange>;

    /**
     *
     * Constructor.
     *
     */
    public function new() {}
}
