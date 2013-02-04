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

    public function toOrder() : Ordering {
        //trace("Align! " + ha + " " + hb);
        var order : Ordering = new Ordering();
        var xa : Int = 0;
        var xas : Int = ha;
        var xb : Int = 0;
        var va : IntHash<Int> = new IntHash<Int>();
        for (i in 0...ha) {
            va.set(i,i);
        }
        while (va.keys().hasNext() || xb<hb) {
            if (xa>=ha) xa = 0;
            //trace("xa " + xa + " xb " + xb);
            if (xa<ha && a2b(xa) == null) {
                if (va.exists(xa)) {
                    //trace("L: " + xa + " -");
                    order.add(xa,-1);
                    va.remove(xa);
                    xas--;
                }
                xa++;
                continue;
            }
            if (xb<hb) {
                var alt : Null<Int> = b2a(xb);
                if (alt!=null) {
                    //trace("R: " + alt + " " + xb);
                    order.add(alt,xb);
                    if (va.exists(alt)) {
                        va.remove(alt);
                        xas--;
                    }
                    xa = (alt+1);
                } else {
                    //trace("R: - " + xb);
                    order.add(-1,xb);
                }
                xb++;
                continue;
            }
            trace("Oops, alignment problem");
            break;
        }
        return order;
    }
}
