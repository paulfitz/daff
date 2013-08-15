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

        var moved : Array<Int> = new Array<Int>();

        while (blks.length>0) {
            var blk : Int = blks.shift();
            var blen : Int = blks.length;
            var ref_src_loc : Int = blk_src_loc.get(blk);
            var ref_dest_loc : Int = blk_dest_loc.get(blk);
            var i : Int = blen-1;
            while (i>=0) {
                var blki : Int = blks[i];
                var blki_src_loc : Int = blk_src_loc.get(blki);
                var to_left_src : Bool = blki_src_loc < ref_src_loc;
                var to_left_dest : Bool = blk_dest_loc.get(blki) < ref_dest_loc;
                if (to_left_src!=to_left_dest) {
                    var ct : Int = blk_len[blki];
                    for (j in 0...ct) {
                        moved.push(src[blki_src_loc]);
                        blki_src_loc++;
                    }
                    blks.splice(i,1);
                }
                i--;
            }
        }
        return moved;
    }
}
