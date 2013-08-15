// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class Mover {

    public function new() {
    }

    public function move(src: Array<Int>, dest: Array<Int>) : Array<Int> {
        if (src.length!=dest.length) return null;
        if (src.length<=1) return src.copy();

        var len : Int = src.length;
        var in_src : Map<Int,Int> = new Map<Int,Int>();
        var blk_len : Map<Int,Int> = new Map<Int,Int>();
        var blk_src_loc : Map<Int,Int> = new Map<Int,Int>();
        var blk_dest_loc : Map<Int,Int> = new Map<Int,Int>();
        for (i in 0...len) {
            in_src[src[i]] = i;
        }
        var ct : Int = 0;
        var in_cursor : Int = -2;
        var out_cursor : Int = 0;
        var next : Int;
        var v : Int;
        var blk : Int = -1;
        while (out_cursor<len) {
            v = dest[out_cursor];
            next = in_src[v];
            if (next != in_cursor+1) {
                blk = v;
                ct = 1;
                blk_src_loc.set(blk,next);
                blk_dest_loc.set(blk,out_cursor);
            } else {
                ct++;
            }
            blk_len.set(blk,ct);
            in_cursor = next;
            out_cursor++;
        }

        var blks : Array<Int> = new Array<Int>();
        for (k in blk_len.keys()) { blks.push(k); }
        blks.sort(function(a,b) { return blk_len.get(b)-blk_len.get(a); });

        var unmoved : Array<Int> = new Array<Int>();
        var moved : Array<Int> = new Array<Int>();

        while (blks.length>0) {
            var blk : Int = blks.shift();
            unmoved.push(blk);
            var blen : Int = blks.length;
            var ref_src_loc : Int = blk_src_loc.get(blk);
            var ref_dest_loc : Int = blk_dest_loc.get(blk);
            var i : Int = blen-1;
            while (i>=0) {
                var blki : Int = blks[i];
                var to_left_src : Bool = blk_src_loc.get(blki) < ref_src_loc;
                var to_left_dest : Bool = blk_dest_loc.get(blki) < ref_dest_loc;
                if (to_left_src!=to_left_dest) {
                    moved.push(blki);
                    blks.splice(i,1);
                }
                i--;
            }
        }
        return moved;
    }

    private var solutions : Int;
    private var global_solved : Bool;
    private var global_best_order : Array<Int>;


    public function bad_move(src: Array<Int>, dest: Array<Int>) : Array<Int> {
        var forbidden : Array<Int> = new Array<Int>();
        var order : Array<Int> = new Array<Int>();
        global_solved = false;
        solutions = 0;
        global_best_order = new Array<Int>();
        submove(src,dest,order,forbidden,0);
        return global_best_order;
    }

    private function submove(src: Array<Int>, dest: Array<Int>, 
                             order: Array<Int>,
                             forbidden: Array<Int>, depth: Int) : Array<Int> {
        //trace(src + " --- " + order);
        if (global_solved) {
            if (depth>global_best_order.length) return null;
        }
        if (solutions>100) return null; // lots of solutions? take any.
        var len : Int = dest.length;
        if (src.length==len) {
            var equal : Bool = true;
            for (i in 0...len) {
                if (src[i]!=dest[i]) { 
                    equal = false;
                    break;
                }
            }
            if (equal) return order;
        }
        var best_order : Array<Int> = new Array<Int>();
        var solved : Bool = false;
        for (i in 0...len) {
            var x : Int = dest[i];
            if (Lambda.has(forbidden,x)) continue;
            var it : Int = Lambda.indexOf(src,x);
            var moving : Bool = false;
            var to_start : Bool = false;
            var x2 : Int = -1;
            if (it==0) {
                if (i!=0) {
                    x2 = dest[i-1];
                    moving = true;
                }
            } else if (i==0) {
                moving = true;
                to_start = true;
            } else if (src[it-1]!=dest[i-1]) {
                x2 = dest[i-1];
                moving = true;
            }
            if (!moving) continue;

            var norder : Array<Int> = order.copy();
            var nforbidden : Array<Int> = forbidden.copy();
            var nsrc : Array<Int> = src.copy();
            nsrc.splice(it,1);
            if (to_start) {
                nsrc.unshift(x);
            } else {
                nsrc.insert(Lambda.indexOf(nsrc,x2)+1,x);
            }
            norder.push(x);
            forbidden.push(x);
            norder = submove(nsrc,dest,norder,nforbidden,depth+1);
            if (norder==null) continue;

            if (norder.length<best_order.length || !solved) {
                best_order = norder.copy();
                solved = true;
                solutions++;
                if (best_order.length<global_best_order.length || 
                    !global_solved) {
                    global_best_order = best_order;
                    global_solved = true;
                }
            }

            if (order.length>20) break; // moving lots of stuff? don't optimize.
        }
        return global_best_order;
    }
}
