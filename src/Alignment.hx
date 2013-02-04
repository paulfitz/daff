// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class Alignment {
    private var map_a2b : IntHash<Int>;
    private var map_b2a : IntHash<Int>;
    private var ha : Int;
    private var hb : Int;
    private var map_count : Int;

    public function new() : Void {
        map_a2b = new IntHash<Int>();
        map_b2a = new IntHash<Int>();
        ha = hb = 0;
        map_count = 0;
    }

    public function range(ha: Int, hb: Int) : Void {
        this.ha = ha;
        this.hb = hb;
    }

    public function link(a: Int, b: Int) : Void {
        map_a2b.set(a,b);
        map_b2a.set(b,a);
        map_count++;
    }

    public function a2b(a: Int) : Null<Int> {
        return map_a2b.get(a);
    }

    public function b2a(b: Int) : Null<Int> {
        return map_b2a.get(b);
    }

    public function count() : Int {
        return map_count;
    }

    public function toString() : String {
        return "" + map_a2b;
    }
}
