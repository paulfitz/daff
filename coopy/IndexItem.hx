// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * A list of instances of a given row in a table.
 *
 */
class IndexItem {
    private var lst : Array<Int>;

    public function new() : Void {
    }

    /**
     *
     * Add an extra instance to the list.
     *
     * @param i the row number
     * @return the number of instances seen
     *
     */
    public inline function add(i: Int) : Int {
        if (lst==null) lst = new Array<Int>();
        lst.push(i);
        return lst.length;
    }

    /**
     *
     * @return the number of instances seen
     *
     */
    public inline function length() : Int {
        return lst.length;
    }

    /**
     *
     * @return the row number of the first instance seen
     *
     */
    public inline function value() : Int {
        return lst[0];
    }

    /**
     *
     * @return the full list of rows seen
     *
     */
    public inline function asList() : Array<Int> {
        return lst;
    }
}
