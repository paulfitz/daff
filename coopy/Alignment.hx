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

    public function toOrderPruned(rowlike: Bool) : Ordering {
        return toOrderCached(true,rowlike);
    }

    public function toOrder() : Ordering {
        return toOrderCached(false,false);
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

    private function toOrderCached(prune: Bool, rowlike: Bool) : Ordering {
        if (order_cache!=null) {
            if (reference!=null) {
                if (!order_cache_has_reference) {
                    order_cache = null;
                }
            }
        }
        if (order_cache==null) order_cache = toOrder3(prune,rowlike);
        if (reference!=null) order_cache_has_reference = true;
        return order_cache;
    }

    // Prune additions/removal pairs that match exactly.
    // This ideally would occur earlier, in the original
    // alignment, like in the original C++ coopy.
    private function pruneOrder(o: Ordering, ref: Alignment,
                                rowlike: Bool) : Void {
        var tl : Table = ref.tb;
        var tr : Table = tb;
        if (rowlike) {
            if (tl.width!=tr.width) return;
        } else {
            if (tl.height!=tr.height) return;
        }
        var units : Array<Unit> = o.getList();
        var left_units : Array<Unit> = new Array<Unit>();
        var left_locs : Array<Int> = new Array<Int>();
        var right_units : Array<Unit> = new Array<Unit>();
        var right_locs : Array<Int> = new Array<Int>();
        var eliminate : Array<Int> = new Array<Int>();
        var ct : Int = 0;
        for (i in 0...units.length) {
            var unit : Unit = units[i];
            if (unit.l<0 && unit.r>=0) {
                right_units.push(unit);
                right_locs.push(i);
                ct++;
            } else if (unit.r<0 && unit.l>=0) {
                left_units.push(unit);
                left_locs.push(i);
                ct++;
            } else if (ct>0) {
                // wish haxe had Array.clear!
                left_units.splice(0,left_units.length);
                right_units.splice(0,right_units.length);
                left_locs.splice(0,left_locs.length);
                right_locs.splice(0,right_locs.length);
                ct = 0;
            }
            while (left_locs.length>0 && right_locs.length>0) {
                var l : Int = left_units[0].l;
                var r : Int = right_units[0].r;
                var view : View = tl.getCellView();
                var match : Bool = true;
                if (rowlike) {
                    var w : Int = tl.width;
                    for (j in 0...w) {
                        if (!view.equals(tl.getCell(j,l),tr.getCell(j,r))) {
                            match = false;
                            break;
                        }
                    }
                } else {
                    var h : Int = tl.height;
                    for (j in 0...h) {
                        if (!view.equals(tl.getCell(l,j),tr.getCell(r,j))) {
                            match = false;
                            break;
                        }
                    }
                }
                if (match) {
                    eliminate.push(left_locs[0]);
                    eliminate.push(right_locs[0]);
                }
                left_units.shift();
                right_units.shift();
                left_locs.shift();
                right_locs.shift();
                ct-=2;
            }
        }
        if (eliminate.length>0) {
            eliminate.sort(function(a,b) return a-b);
            var del : Int = 0;
            for (e in eliminate) {
                o.getList().splice(e-del,1);
                del++;
            }
        }
    }

    private function toOrder3(prune: Bool, rowlike: Bool) : Ordering {
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
        if (prune) {
            pruneOrder(order,ref,rowlike);
        }
        return order;
    }
}
