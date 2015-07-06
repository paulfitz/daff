// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Store the relationship between tables. Answers the question: where
 * does a row/column of table A appear in table B?
 *
 */
class Alignment {
    private var map_a2b : Map<Int,Int>;
    private var map_b2a : Map<Int,Int>;
    private var ha : Int;
    private var hb : Int;
    private var ta : Table;
    private var tb : Table;
    private var ia : Int;
    private var ib : Int;
    private var map_count : Int;
    private var order_cache : Ordering;
    private var order_cache_has_reference : Bool;
    private var index_columns : Array<Unit>;
    private var marked_as_identical : Bool;

    public var reference: Alignment;
    public var meta: Alignment;
    public var comp: TableComparisonState;
    public var has_addition : Bool;
    public var has_removal : Bool;

    public function new() : Void {
        map_a2b = new Map<Int,Int>();
        map_b2a = new Map<Int,Int>();
        ha = hb = 0;
        map_count = 0;
        reference = null;
        meta = null;
        comp = null;
        order_cache_has_reference = false;
        ia = -1;
        ib = -1;
        marked_as_identical = false;
    }

    /**
     *
     * Record the heights of tables A and B.
     *
     */
    public function range(ha: Int, hb: Int) : Void {
        this.ha = ha;
        this.hb = hb;
    }

    /**
     *
     * Keep references to tables A and B.  The `Alignment` class never
     * looks at these tables itself, these references are stored only
     * for the convenience of users of the alignment.
     *
     */
    public function tables(ta: Table, tb: Table) : Void {
        this.ta = ta;
        this.tb = tb;
    }

    /**
     *
     * Mark the header rows of tables A and B, if present.
     * Not applicable for column alignments.
     *
     * @param ia index of the header row of table A
     * @param ia index of the header row of table B
     *
     */
    public function headers(ia: Int, ib: Int) : Void {
        this.ia = ia;
        this.ib = ib;
    }

    /**
     *
     * Set whether we are aligning rows or columns.
     *
     * @param flag true when aligning rows, false when aligning columns
     *
     */
    public function setRowlike(flag: Bool) : Void {
    }

    /**
     *
     * Declare the specified rows/columns to be the "same" row/column
     * in the two tables.
     *
     * @param a row/column in table A
     * @param b row/column in table B
     *
     */
    public function link(a: Int, b: Int) : Void {
        if (a!=-1) {
            map_a2b.set(a,b);
        } else {
            has_addition = true;
        }
        if (b!=-1) {
            map_b2a.set(b,a);
        } else {
            has_removal = true;
        }
        map_count++;
    }

    /**
     *
     * Record a column as being important for identifying rows.
     * This is important for making sure it gets preserved in
     * diffs, for example.
     *
     * @param unit the column's location in table A (l/left) and
     * in table B (r/right).
     *
     */
    public function addIndexColumns(unit: Unit) : Void {
        if (index_columns==null) {
            index_columns = new Array<Unit>();
        }
        index_columns.push(unit);
    }

    /**
     *
     * @return a list of columns important for identifying rows
     *
     */
    public function getIndexColumns() : Array<Unit> {
        return index_columns;
    }

    /**
     *
     * @return given a row/column number in table A, this returns
     * the row/column number in table B (or null if not in that table)
     *
     */
    public function a2b(a: Int) : Null<Int> {
        return map_a2b.get(a);
    }

    /**
     *
     * @return given a row/column number in table B, this returns
     * the row/column number in table A (or null if not in that table)
     *
     */
    public function b2a(b: Int) : Null<Int> {
        return map_b2a.get(b);
    }

    /**
     *
     * @return a count of how many row/columns have been linked
     *
     */
    public function count() : Int {
        return map_count;
    }

    /**
     *
     * @return text representation of alignment
     *
     */
    public function toString() : String {
        var result = "" + map_a2b + " // " + map_b2a;
        if (reference!=null) {
            result += " (" + reference + ")";
        }
        return result;
    }

    /**
     *
     * @return an ordered version of the alignment, as a merged list
     * of rows/columns
     *
     */
    public function toOrder() : Ordering {
        if (order_cache!=null) {
            if (reference!=null) {
                if (!order_cache_has_reference) {
                    order_cache = null;
                }
            }
        }
        if (order_cache==null) order_cache = toOrder3();
        if (reference!=null) order_cache_has_reference = true;
        return order_cache;
    }

    /**
     *
     * Manually set an ordered version of the alignment.
     * @param l row/column number in local table
     * @param r row/column number in remote table
     * @param p row/column number in parent table (if there is one)
     *
     */
    public function addToOrder(l: Int, r: Int, ?p: Int = -2) {
        if (order_cache==null) order_cache = new Ordering();
        order_cache.add(l,r,p);
        order_cache_has_reference = (p!=-2);
    }

    /**
     *
     * @return table A
     *
     */
    public function getSource() : Table {
        return ta;
    }

    /**
     *
     * @return table B
     *
     */
    public function getTarget() : Table {
        return tb;
    }

    /**
     *
     * Get the header row for table A, if present.
     *
     * @return header row for table A, or -1 if not present or not applicable
     *
     */
    public function getSourceHeader() : Int {
        return ia;
    }

    /**
     *
     * Get the header row for table B, if present.
     *
     * @return header row for table B, or -1 if not present or not applicable
     *
     */
    public function getTargetHeader() : Int {
        return ib;
    }

    private function toOrder3() : Ordering {
        var order = new Array<Unit>();
        if (reference==null) {
            for (k in map_a2b.keys()) {
                var unit = new Unit();
                unit.l = k;
                unit.r = a2b(k);
                order.push(unit);
            }
            for (k in map_b2a.keys()) {
                if (b2a(k)==-1) {
                    var unit = new Unit();
                    unit.l = -1;
                    unit.r = k;
                    order.push(unit);
                }
            }
        } else {
            for (k in map_a2b.keys()) {
                var unit = new Unit();
                unit.p = k;
                unit.l = reference.a2b(k);
                unit.r = a2b(k);
                order.push(unit);
            }
            for (k in reference.map_b2a.keys()) {
                if (reference.b2a(k)==-1) {
                    var unit = new Unit();
                    unit.p = -1;
                    unit.l = k;
                    unit.r = -1;
                    order.push(unit);
                }
            }
            for (k in map_b2a.keys()) {
                if (b2a(k)==-1) {
                    var unit = new Unit();
                    unit.p = -1;
                    unit.l = -1;
                    unit.r = k;
                    order.push(unit);
                }
            }
        }
        var top = order.length;
        var remotes = new Array<Int>();
        var locals = new Array<Int>();
        for (o in 0...top) {
            if (order[o].r >= 0) {
                remotes.push(o);
            } else {
                locals.push(o);
            }
        }
        var remote_sort = function(a,b) {
            return order[a].r-order[b].r;
        }
        var local_sort = function(a,b) {
            if (a==b) return 0; // java does this
            if (order[a].l>=0 && order[b].l>=0) {
                return order[a].l-order[b].l;
            }
            if (order[a].l>=0) return 1;
            if (order[b].l>=0) return -1;
            return a-b;
        }
        if (reference!=null) {
            remote_sort = function(a,b) {
                if (a==b) return 0; // java does this
                var o1 = order[a].r-order[b].r;
                if (order[a].p>=0&&order[b].p>=0) {
                    var o2 = order[a].p-order[b].p;
                    if (o1*o2<0) {
                        return o1;
                    }
                    var o3 = order[a].l-order[b].l;
                    return o3;
                }
                return o1;
            }
            local_sort = function(a,b) {
                if (a==b) return 0; // java does this
                if (order[a].l>=0 && order[b].l>=0) {
                    var o1 = order[a].l-order[b].l;
                    if (order[a].p>=0&&order[b].p>=0) {
                        var o2 = order[a].p-order[b].p;
                        if (o1*o2<0) {
                            return o1;
                        }
                        return o2;
                    }
                }
                if (order[a].l>=0) return 1;
                if (order[b].l>=0) return -1;
                return a-b;
            }
        }
        remotes.sort(remote_sort);
        locals.sort(local_sort);
        var revised_order = new Array<Unit>();
        var at_r = 0;
        var at_l = 0;
        for (o in 0...top) {
            if (at_r<remotes.length && at_l<locals.length) {
                var ur = order[remotes[at_r]];
                var ul = order[locals[at_l]];
                if (ul.l==-1 && ul.p>=0 && ur.p>=0) {
                    if (ur.p>ul.p) {
                        revised_order.push(ul);
                        at_l++;
                        continue;
                    }
                } else if (ur.l>ul.l) {
                    revised_order.push(ul);
                    at_l++;
                    continue;
                }
                revised_order.push(ur);
                at_r++;
                continue;
            }
            if (at_r<remotes.length) {
                var ur = order[remotes[at_r]];
                revised_order.push(ur);
                at_r++;
                continue;
            }
            if (at_l<locals.length) {
                var ul = order[locals[at_l]];
                revised_order.push(ul);
                at_l++;
                continue;
            }
        }
        order = revised_order;

        var result = new Ordering();
        result.setList(order);
        if (reference==null) result.ignoreParent();
        return result;
    }

    public function markIdentical() {
        marked_as_identical = true;
    }

    public function isMarkedAsIdentical() : Bool {
        return marked_as_identical;
    }
}
