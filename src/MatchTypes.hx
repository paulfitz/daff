// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class MatchTypes {
    private var matches : Array<MatchType>;
    private var comp: Comparison;
    private var align: Alignment;
    private var wide_top_freq: Int;
    private var wide_ambiance_a: Hash<Int>;
    private var wide_ambiance_b: Hash<Int>;
    private var v : View;

    public function new(comp: Comparison, align: Alignment) : Void {
        matches = new Array<MatchType>();
        this.comp = comp;
        this.align = align;
    }

    public function add(col: Int, val: Datum) : Void {
        var mt : MatchType = new MatchType();
        mt.col = col;
        mt.val = val;
        matches.push(mt);
    }

    public function toKey(t: Table, i: Int = -1) : String {
        var wide : String = "";
        for (k in 0...matches.length) {
            var mt : MatchType = matches[k];
            var d : Datum = (i>=0) ? t.getCell(mt.col,i) : mt.val;
            var txt : String = v.toString(d);
            if (k>0) wide += " // ";
            wide += txt;
        }
        return wide;
    }

    public function accumTable(t: Table,wide_ambiance: Hash<Int>) : Int {
        var spot_count : Int = 0;
        var spot_key : String = toKey(t);
        var h : Int = t.height;
        for (i in 0...h) {
            var freq: Int = 1;
            var wide: String = toKey(t,i);
            if (wide_ambiance.exists(wide)) {
                freq = wide_ambiance.get(wide)+1;
            }
            wide_ambiance.set(wide,freq);
            if (freq>wide_top_freq) {
                wide_top_freq = freq;
            }
            if (wide==spot_key) spot_count++;
        }
        return spot_count;
    }

    public function evaluate() : Bool {
        if (matches.length==0) return false;
        wide_ambiance_a = new Hash<Int>();
        wide_ambiance_b = new Hash<Int>();
        wide_top_freq = 0;
        v = comp.a.getCellView();
        var spot_a : Int = accumTable(comp.a,wide_ambiance_a);
        var spot_b : Int = accumTable(comp.b,wide_ambiance_b);
        if (spot_a!=1 || spot_b!=1) return false;
        if (wide_top_freq == 1) return true;
        // Our particular matching values are unique in their
        // respective tables.  However, there exist other rows 
        // that have matching values that are not unique.
        var h : Int = comp.a.height;
        if (comp.b.height>h) h = comp.b.height;
        if (h<1) h = 1;
        var ratio : Float = wide_top_freq;
        ratio /= (h+20); // "20" allows for low-data case
        //trace("Ratio is " + ratio);
        if (ratio<0.1) return true;
        return false;
    }
}
