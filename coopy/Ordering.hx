// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * An ordered list of units, representing a merged view of rows
 * in a local, remote, and (optionally) parent table.
 *
 */
class Ordering {
    private var order : Array<Unit>;
    private var ignore_parent : Bool;

    public function new() : Void {
        order = new Array<Unit>();
        ignore_parent = false;
    }

    /**
     *
     * Add a local/remote/parent triplet.
     *
     * @param l the row/column number in the local table (-1 means absent)
     * @param r the row/column number in the remote table (-1 means absent)
     * @param p the row/column number in the parent table (-1 means absent,
     * -2 means there is no parent)
     *
     */
    public function add(l: Int, r: Int, p: Int = -2) : Void {
        if (ignore_parent) p = -2;
        order.push(new Unit(l,r,p));
    }

    /**
     *
     * @return the list of units in this ordering
     *
     */
    public function getList() : Array<Unit> {
        return order;
    }

    /**
     *
     * Replace the order with a prepared list.
     *
     * @param lst the new order
     *
     */
    public function setList(lst: Array<Unit>) {
        order = lst;
    }

    /**
     *
     * @return the list of units in text form
     *
     */
    public function toString() : String {
        var txt : String = "";
        for (i in 0...order.length) {
            if (i>0) txt += ", ";
            txt += order[i];
        }
        return txt;
    }

    /**
     *
     * Force any parent row/column numbers to be ignored and discarded.
     *
     */
    public function ignoreParent() : Void {
        ignore_parent = true;
    }
}
