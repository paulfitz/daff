// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class MatchTypes {
    private var matches : Match;
    private var comp: Comparison;
    private var align: Alignment;

    private var index : IndexPair;
    private var indexes : Hash<IndexPair>;

    private var local : Table;
    private var remote : Table;

    public function new(comp: Comparison, align: Alignment,
                        local: Table, remote: Table,
                        indexes: Hash<IndexPair>) : Void {
        matches = new Match();
        this.indexes = indexes;
        this.comp = comp;
        this.align = align;
        this.local = local;
        this.remote = remote;
    }

    public function add(col: Int, val: Datum) : Void {
        var mt : MatchType = new MatchType();
        mt.col = col;
        mt.val = val;
        matches.matches.push(mt);
    }

    public function evaluate() : Bool {
        if (matches.matches.length==0) return false;

        var add_col = function(c:Int,total:String) { return total += c; };
        var get_col = function(m) { return m.col; };
        var indexName : String = Lambda.fold(Lambda.map(matches.matches,get_col),add_col,"");

        index = indexes.get(indexName);
      
        if (index==null) {
            index = new IndexPair();
            for (k in 0...matches.matches.length) {
                var mt : MatchType = matches.matches[k];
                index.addColumn(mt.col);
            }
            index.indexTables(local,remote);
            indexes.set(indexName,index);
        }
        var cross: CrossMatch = index.query(matches);

        var spot_a : Int = cross.spot_a;
        var spot_b : Int = cross.spot_b;
        var wide_top_freq : Int = index.getTopFreq();
        if (spot_a!=1 || spot_b!=1) return false;
        if (wide_top_freq == 1) return true;
        // Our particular matching values are unique in their
        // respective tables.  However, there exist other rows 
        // that have matching values that are not unique.
        var h : Int = local.height;
        if (remote.height>h) h = remote.height;
        if (h<1) h = 1;
        var ratio : Float = wide_top_freq;
        ratio /= (h+20); // "20" allows for low-data 
        //trace("Ratio is " + ratio);
        if (ratio<0.1) return true;
        return false;
    }
}
