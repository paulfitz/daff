// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

class Alignment {
    private var map_a2b : Map<Int,Int>;
    private var map_b2a : Map<Int,Int>;
    private var ha : Int;
    private var hb : Int;
    private var ta : Table;
    private var tb : Table;
    private var map_count : Int;
    private var order_cache : Ordering;
    private var order_cache_has_reference : Bool;

    public var reference: Alignment;
    public var meta: Alignment;

    public function new() : Void {
        map_a2b = new Map<Int,Int>();
        map_b2a = new Map<Int,Int>();
        ha = hb = 0;
        map_count = 0;
        reference = null;
        meta = null;
        order_cache_has_reference = false;
    }

    public function range(ha: Int, hb: Int) : Void {
        this.ha = ha;
        this.hb = hb;
    }

    public function tables(ta: Table, tb: Table) : Void {
        this.ta = ta;
        this.tb = tb;
    }

    public function setRowlike(flag: Bool) : Void {
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

    public function getSource() : Table {
        return ta;
    }

    public function getTarget() : Table {
        return tb;
    }

    private function toOrder3() : Ordering {
        var ref : Alignment = reference;
        if (ref == null) {
            ref = new Alignment();
            ref.range(ha,ha);
            ref.tables(ta,ta);
            for (i in 0...ha) {
                ref.link(i,i);
            }
        }
        var order : Ordering = new Ordering();
        if (reference==null) {
            order.ignoreParent();
        }
        var xp : Int = 0;
        var xl : Int = 0;
        var xr : Int = 0;
        var hp : Int = ha;
        var hl : Int = ref.hb;
        var hr : Int = hb;
        var vp : Map<Int,Int> = new Map<Int,Int>();
        var vl : Map<Int,Int> = new Map<Int,Int>();
        var vr : Map<Int,Int> = new Map<Int,Int>();
        for (i in 0...hp) vp.set(i,i);
        for (i in 0...hl) vl.set(i,i);
        for (i in 0...hr) vr.set(i,i);
        var ct_vp: Int = hp;
        var ct_vl: Int = hl;
        var ct_vr: Int = hr;
        var prev : Int = -1;
        var ct : Int = 0;
        var max_ct = (hp+hl+hr)*10;
        while (ct_vp>0 || 
               ct_vl>0 || 
               ct_vr>0) {
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
            if (xp<hp && ct_vp>0) {
                if (a2b(xp) == null &&
                    ref.a2b(xp) == null) {
                    if (vp.exists(xp)) {
                        //trace("P xp/xl/xr " + xp + " " + xl + " " + xr);
                        order.add(-1,-1,xp);
                        prev = xp;
                        vp.remove(xp);
                        ct_vp--;
                    }
                    xp++;
                    continue;
                }
            }
            var zl : Null<Int> = null;
            var zr : Null<Int> = null;
            if (xl<hl && ct_vl>0) {
                zl = ref.b2a(xl);
                if (zl==null) {
                    if (vl.exists(xl)) {
                        //trace("L xp/xl/xr " + xp + " " + xl + " " + xr);
                        order.add(xl,-1,-1);
                        //prev = -1;
                        vl.remove(xl);
                        ct_vl--;
                    }
                    xl++;
                    continue;
                }
            }
            if (xr<hr && ct_vr>0) {
                zr = b2a(xr);
                if (zr==null) {
                    if (vr.exists(xr)) {
                        //trace("R xp/xl/xr " + xp + " " + xl + " " + xr);
                        order.add(-1,xr,-1);
                        //prev = -1;
                        vr.remove(xr);
                        ct_vr--;
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
                        ct_vp--;
                        vl.remove(xl);
                        ct_vl--;
                        xp = zl+1; //HIT
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
                        ct_vp--;
                        vr.remove(xr);
                        ct_vr--;
                        xp = zr+1;
                    }
                    xr++;
                    continue;
                }
            }
            /*
            if (zl!=null && zr!=null && zr == zl) {
                trace("left and right in sync");
                continue;
            }
            */
            if (zl!=null && zr!=null && a2b(zl)!=null && 
                ref.a2b(zr)!=null) {
                //trace("We have a choice of order " + zl + " " + zr + " prev is " + prev);
                // we have a choice of order
                // local thinks zl should come next
                // remote thinks zr should come next
                if (zl==prev+1) {
                    //trace("left is boring, use right");
                    if (vr.exists(xr)) {
                        //trace("R xp/xl/xr " + xp + " " + xl + " " + xr);
                        order.add(ref.a2b(zr),xr,zr);
                        prev = zr;
                        vp.remove(zr);
                        ct_vp--;
                        vl.remove(ref.a2b(zr));
                        ct_vl--;
                        vr.remove(xr);
                        ct_vr--;
                        xp = zr+1;
                        xl = ref.a2b(zr)+1;
                    }
                    xr++;
                    continue;
                } else {
                    //trace("using left");
                    if (vl.exists(xl)) {
                        //trace("L xp/xl/xr " + xp + " " + xl + " " + xr);
                        order.add(xl,a2b(zl),zl);
                        prev = zl;
                        vp.remove(zl);
                        ct_vp--;
                        vl.remove(xl);
                        ct_vl--;
                        vr.remove(a2b(zl));
                        ct_vr--;
                        xp = zl+1;
                        xr = a2b(zl)+1;
                    }
                    xl++;
                    continue;
                }
            }
            xp++;
            xl++;
            xr++;
        }
        //trace("RESULT " + order.toString());
        return order;
    }

    // this function is no longer used, could be brought back
    // as stripped-down version of toOrder3 once that is stable.
    private function toOrder2() : Ordering {
        //trace("Align! " + ha + " " + hb);
        var order : Ordering = new Ordering();
        var xa : Int = 0;
        var xas : Int = ha;
        var xb : Int = 0;
        var va : Map<Int,Int> = new Map<Int,Int>();
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
