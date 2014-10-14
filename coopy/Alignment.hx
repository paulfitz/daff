// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

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
        ia = 0;
        ib = 0;
    }

    public function range(ha: Int, hb: Int) : Void {
        this.ha = ha;
        this.hb = hb;
    }

    public function tables(ta: Table, tb: Table) : Void {
        this.ta = ta;
        this.tb = tb;
    }

    public function headers(ia: Int, ib: Int) : Void {
        this.ia = ia;
        this.ib = ib;
    }

    public function setRowlike(flag: Bool) : Void {
    }

    public function link(a: Int, b: Int) : Void {
        map_a2b.set(a,b);
        map_b2a.set(b,a);
        map_count++;
    }

    public function addIndexColumns(unit: Unit) : Void {
        if (index_columns==null) {
            index_columns = new Array<Unit>();
        }
        index_columns.push(unit);
    }

    public function getIndexColumns() : Array<Unit> {
        return index_columns;
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

    public function getSourceHeader() : Int {
        return ia;
    }

    public function getTargetHeader() : Int {
        return ib;
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
            if (xp<hp && ct_vp>0) {
                if (a2b(xp) == null &&
                    ref.a2b(xp) == null) {
                    if (vp.exists(xp)) {
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
                        order.add(xl,-1,-1);
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
                        order.add(-1,xr,-1);
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
                        order.add(xl,-1,zl);
                        prev = zl;
                        vp.remove(zl);
                        ct_vp--;
                        vl.remove(xl);
                        ct_vl--;
                        xp = zl+1;
                    }
                    xl++;
                    continue;
                }
            }
            if (zr!=null) {
                if (ref.a2b(zr)==null) {
                    // row deleted in local
                    if (vr.exists(xr)) {
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
            if (zl!=null && zr!=null && a2b(zl)!=null && 
                ref.a2b(zr)!=null) {
                // we have a choice of order
                // local thinks zl should come next
                // remote thinks zr should come next
                if (zl==prev+1 || zr!=prev+1) {
                    if (vr.exists(xr)) {
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
                    if (vl.exists(xl)) {
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
        return order;
    }
}
