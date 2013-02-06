// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class Alignment {
    private var map_a2b : IntHash<Int>;
    private var map_b2a : IntHash<Int>;
    private var ha : Int;
    private var hb : Int;
    private var ta : Table;
    private var tb : Table;
    private var map_count : Int;
    private var order_cache : Ordering;

    public var reference: Alignment;

    public function new() : Void {
        map_a2b = new IntHash<Int>();
        map_b2a = new IntHash<Int>();
        ha = hb = 0;
        map_count = 0;
        reference = null;
    }

    public function range(ha: Int, hb: Int) : Void {
        this.ha = ha;
        this.hb = hb;
    }

    public function tables(ta: Table, tb: Table) : Void {
        this.ta = ta;
        this.tb = tb;
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
        if (order_cache==null) order_cache = toOrder3();
        return order_cache;
    }

    public function getSource() : Table {
        return ta;
    }

    public function getTarget() : Table {
        return tb;
    }

    private function toOrder3() : Ordering {
        if (reference==null) return toOrder2();
        var ref : Alignment = reference;
        var order : Ordering = new Ordering();
        var xp : Int = 0;
        var xl : Int = 0;
        var xr : Int = 0;
        var hp : Int = ha;
        var hl : Int = ref.hb;
        var hr : Int = hb;
        var vp : IntHash<Int> = new IntHash<Int>();
        var vl : IntHash<Int> = new IntHash<Int>();
        var vr : IntHash<Int> = new IntHash<Int>();
        for (i in 0...hp) vp.set(i,i);
        for (i in 0...hl) vl.set(i,i);
        for (i in 0...hr) vr.set(i,i);
        var prev : Int = -1;
        var ct : Int = 0;
        var max_ct = (hp+hl+hr)*10;
        while (vp.keys().hasNext() || 
               vl.keys().hasNext() || 
               vr.keys().hasNext()) {
            ct++;
            if (ct>max_ct) {
                trace("Ordering took too long, something went wrong");
                break;
            }
            if (xp>=hp) xp = 0;
            if (xl>=hl) xl = 0;
            if (xr>=hr) xr = 0;
            //trace("*** " + order);
            //trace("At " + xp + " " + xl + " " + xr);
            //trace("hs " + hp + " " + hl + " " + hr);
            if (xp<hp && vp.keys().hasNext()) {
                if (a2b(xp) == null &&
                    ref.a2b(xp) == null) {
                    if (vp.exists(xp)) {
                        //trace("P xp/xl/xr " + xp + " " + xl + " " + xr);
                        order.add(-1,-1,xp);
                        prev = xp;
                        vp.remove(xp);
                    }
                    xp++;
                    continue;
                }
            }
            var zl : Null<Int> = null;
            var zr : Null<Int> = null;
            if (xl<hl && vl.keys().hasNext()) {
                zl = ref.b2a(xl);
                if (zl==null) {
                    if (vl.exists(xl)) {
                        //trace("L xp/xl/xr " + xp + " " + xl + " " + xr);
                        order.add(xl,-1,-1);
                        prev = -1;
                        vl.remove(xl);
                    }
                    xl++;
                    continue;
                }
            }
            if (xr<hr && vr.keys().hasNext()) {
                zr = b2a(xr);
                if (zr==null) {
                    if (vr.exists(xr)) {
                        //trace("R xp/xl/xr " + xp + " " + xl + " " + xr);
                        order.add(-1,xr,-1);
                        prev = -1;
                        vr.remove(xr);
                    }
                    xr++;
                    continue;
                }
            }
            if (zl!=null) {
                if (a2b(zl)==null) {
                    // row deleted in remote
                    if (vl.exists(xl)) {
                        //trace("L xp/xl/xr " + xp + " " + xl + " " + xr);
                        order.add(xl,-1,zl);
                        prev = zl;
                        vp.remove(zl);
                        vl.remove(xl);
                        xp = zl;
                    }
                    xl++;
                    continue;
                }
            }
            if (zr!=null) {
                if (ref.a2b(zr)==null) {
                    // row deleted in local
                    if (vr.exists(xr)) {
                        //trace("R xp/xl/xr " + xp + " " + xl + " " + xr);
                        order.add(-1,xr,zr);
                        prev = zr;
                        vp.remove(zr);
                        vr.remove(xr);
                        xp = zr;
                    }
                    xr++;
                    continue;
                }
            }
            if (zl!=null && zr!=null && a2b(zl)!=null && 
                ref.a2b(zr)!=null) {
                // we have a choice of order
                // local thinks zl should come next
                // remote thinks zr should come next
                if (zl==prev+1) {
                    if (vr.exists(xr)) {
                        //trace("R xp/xl/xr " + xp + " " + xl + " " + xr);
                        order.add(ref.a2b(zr),xr,zr);
                        prev = zr;
                        vp.remove(zr);
                        vl.remove(ref.a2b(zr));
                        vr.remove(xr);
                        xp = zr;
                        xl = ref.a2b(zr);
                    }
                    xr++;
                    continue;
                } else {
                    if (vl.exists(xl)) {
                        //trace("L xp/xl/xr " + xp + " " + xl + " " + xr);
                        order.add(xl,a2b(zl),zl);
                        prev = zl;
                        vp.remove(zl);
                        vl.remove(xl);
                        vr.remove(a2b(zl));
                        xp = zl;
                        xr = a2b(zl);
                    }
                    xl++;
                    continue;
                }
            }
            xp++;
            xl++;
            xr++;
        }
        return order;
    }

    private function toOrder2() : Ordering {
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
