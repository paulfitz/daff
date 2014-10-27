// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Query results when looking for a row in an index pair.
 *
 */
class CrossMatch {
    /**
     *
     * How many times was the query seen in table A.
     *
     */
    public var spot_a : Int;

    /**
     *
     * How many times was the query seen in table B.
     *
     */
    public var spot_b : Int;

    /**
     *
     * List of occurance in table A.
     *
     */
    public var item_a : IndexItem;

    /**
     *
     * List of occurance in table B.
     *
     */
    public var item_b : IndexItem;

    public function new() : Void {
    }
}