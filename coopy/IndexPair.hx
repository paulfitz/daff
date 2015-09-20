// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * An index of rows in two tables. We add a list of columns to use
 * as a key. Rows in the two tables that have the same key are
 * treated as matches. Good indexes have distinct keys within a
 * table, and keys that match (ideally just once) across tables.
 *
 */
class IndexPair {
    private var ia : Index;
    private var ib : Index;
    private var hdr : Int;
    private var quality : Float;
    private var flags : CompareFlags;

    public function new(flags: CompareFlags) : Void {
        this.flags = flags;
        ia = new Index(flags);
        ib = new Index(flags);
        quality = 0;
        hdr = 0;
       }

    /**
     *
     * Add a column in each table to treat as part of a key.
     * Fine to call repeatedly.
     *
     * @param ca column in first table
     * @param cb column in second table
     *
     */
    public function addColumns(ca: Int, cb: Int) : Void {
        ia.addColumn(ca);
        ib.addColumn(cb);
    }

    /**
     *
     * Go ahead and index all the rows in the given tables.
     * Make sure to call `addColumns` first.
     *
     * @param a the first reference table
     * @param a the second table
     *
     */
    public function indexTables(a: Table, b: Table, hdr: Int) : Void {
        ia.indexTable(a,hdr);
        ib.indexTable(b,hdr);
        this.hdr = hdr;
        // calculate
        //   P(present and unique within a AND present and unique with b)
        //     for rows in a
        var good : Int = 0;
        for (key in ia.items.keys()) {
            var item_a : IndexItem = ia.items.get(key);
            var spot_a : Int = item_a.length();
            var item_b : IndexItem = ib.items.get(key);
            var spot_b : Int = 0;
            if (item_b!=null) spot_b = item_b.length();
            if (spot_a == 1 && spot_b == 1) {
                good++;
            }
        }
        quality = good/Math.max(1.0,a.height);
    }

    private function queryByKey(ka: String) : CrossMatch {
        var result : CrossMatch = new CrossMatch();
        result.item_a = ia.items.get(ka);
        result.item_b = ib.items.get(ka);
        result.spot_a = result.spot_b = 0;
        if (ka!="") {
            if (result.item_a!=null) result.spot_a = result.item_a.length();
            if (result.item_b!=null) result.spot_b = result.item_b.length();
        }
        return result;
    }

    /**
     *
     * Find matches for a given row.
     *
     * @return match information
     *
     */
    public function queryByContent(row: Row) : CrossMatch {
        var result : CrossMatch = new CrossMatch();
        var ka : String = ia.toKeyByContent(row);
        return queryByKey(ka);
    }

    /**
     *
     * Find matches for a given row in the first (local) table.
     *
     * @return match information
     *
     */
    public function queryLocal(row: Int) : CrossMatch {
        var ka : String = ia.toKey(ia.getTable(),row);
        return queryByKey(ka);
    }

    /**
     *
     * Get the key of a row in the first (local) table.
     *
     * @param row the row to get a key for
     * @return the key
     *
     */
    public function localKey(row: Int) : String {
        return ia.toKey(ia.getTable(),row);
    }

    /**
     *
     * Get the key of a row in the second (remote) table.
     *
     * @param row the row to get a key for
     * @return the key
     *
     */
    public function remoteKey(row: Int) : String {
        return ib.toKey(ib.getTable(),row);
    }

    /**
     *
     * Get the highest number of key collisions for any given key
     * within an individual table.  High numbers of collisions are
     * a bad sign.
     *
     * @return frequency of key collisions
     *
     */
    public function getTopFreq() : Int {
        if (ib.top_freq>ia.top_freq) return ib.top_freq;
        return ia.top_freq;
    }

    /**
     *
     * Get a measure of the quality of this index pair.  Higher values
     * are better.
     *
     * @return index quality
     *
     */
    public function getQuality() : Float {
        return quality;
    }
}
