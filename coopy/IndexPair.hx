// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

class IndexPair {
    private var ia : Index;
    private var ib : Index;
    private var quality : Float;

    public function new() : Void {
        ia = new Index();
        ib = new Index();
        quality = 0;
    }

    public function addColumn(i: Int) : Void {
        ia.addColumn(i);
        ib.addColumn(i);
    }

    public function addColumns(ca: Int, cb: Int) : Void {
        ia.addColumn(ca);
        ib.addColumn(cb);
    }

    public function indexTables(a: Table, b: Table) : Void {
        ia.indexTable(a);
        ib.indexTable(b);
        // calculate
        //   P(present and unique within a AND present and unique with b)
        //     for rows in a
        var good : Int = 0;
        for (key in ia.items.keys()) {
            var item_a : IndexItem = ia.items.get(key);
            var spot_a : Int = item_a.lst.length;
            var item_b : IndexItem = ib.items.get(key);
            var spot_b : Int = 0;
            if (item_b!=null) spot_b = item_b.lst.length;
            if (spot_a == 1 && spot_b == 1) {
                good++;
            }
        }
        quality = good/Math.max(1.0,a.height);
    }

    public function queryLocal(row: Int) : CrossMatch {
        var result : CrossMatch = new CrossMatch();
        var ka : String = ia.toKey(ia.getTable(),row);
        result.item_a = ia.items.get(ka);
        result.item_b = ib.items.get(ka);
        result.spot_a = result.spot_b = 0;
        if (ka!="") {
            if (result.item_a!=null) result.spot_a = result.item_a.lst.length;
            if (result.item_b!=null) result.spot_b = result.item_b.lst.length;
        }
        return result;
    }


    public function query(match: Match) : CrossMatch {
        var result : CrossMatch = new CrossMatch();
        var ka : String = ia.matchToKey(match);
        var kb : String = ib.matchToKey(match);
        result.item_a = ia.items.get(ka);
        result.item_b = ib.items.get(kb);
        result.spot_a = result.spot_b = 0;
        if (ka!=""||kb!="") {
            if (result.item_a!=null) result.spot_a = result.item_a.lst.length;
            if (result.item_b!=null) result.spot_b = result.item_b.lst.length;
        }
        return result;
    }

    public function getTopFreq() : Int {
        if (ib.top_freq>ia.top_freq) return ib.top_freq;
        return ia.top_freq;
    }

    public function getQuality() : Float {
        return quality;
    }
}
