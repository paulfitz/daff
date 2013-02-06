// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class IndexPair {
    private var ia : Index;
    private var ib : Index;

    public function new() : Void {
        ia = new Index();
        ib = new Index();
    }

    public function addColumn(i: Int) : Void {
        ia.addColumn(i);
        ib.addColumn(i);
    }

    public function indexTables(a: Table, b: Table) : Void {
        ia.indexTable(a);
        ib.indexTable(b);
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
}
