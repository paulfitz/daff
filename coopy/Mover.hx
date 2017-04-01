// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Choose the simplest order in which to move rows/columns.
 *
 */
@:expose
class Mover {

    /**
     *
     * Given a list of matched rows/columns in a desired order, return
     * a list of which units should be moved first.
     *
     * @param units the units to plan a move for
     * @return a list of unit numbers, with units that should move first
     * before units that should move later
     *
     */
    static public function moveUnits(units: Array<Unit>) : Array<Int> {
        var isrc : Array<Int> = new Array<Int>();
        var idest : Array<Int> = new Array<Int>();
        var len : Int = units.length;
        var ltop : Int = -1;
        var rtop : Int = -1;
        var in_src : Map<Int,Int> = new Map<Int,Int>();
        var in_dest : Map<Int,Int> = new Map<Int,Int>();
        for (i in 0...len) {
            var unit : Unit = units[i];
            if (unit.l>=0 && unit.r>=0) {
                if (ltop<unit.l) ltop = unit.l;
                if (rtop<unit.r) rtop = unit.r;
                in_src[unit.l] = i;
                in_dest[unit.r] = i;
            }
        }
        var v : Null<Int>;
        for (i in 0...ltop+1) {
            v = in_src[i];
            if (v!=null) isrc.push(v);
        }
        for (i in 0...rtop+1) {
            v = in_dest[i];
            if (v!=null) idest.push(v);
        }
        return moveWithoutExtras(isrc,idest);
    }

    /**
     *
     * Given a list and a shuffled version of that list, plan a good
     * order in which to move elements of the list
     *
     * @param isrc the reference list
     * @param idest a shuffled version of the reference list
     * @return a list of elements, with elements that should move first
     * before elements that should move later
     *
     */
    static public function move(isrc: Array<Int>, idest: Array<Int>) : Array<Int> {
        var len : Int = isrc.length;
        var len2 : Int = idest.length;
        var in_src : Map<Int,Int> = new Map<Int,Int>();
        var in_dest : Map<Int,Int> = new Map<Int,Int>();
        for (i in 0...len) {
            in_src[isrc[i]] = i;
        }
        for (i in 0...len2) {
            in_dest[idest[i]] = i;
        }
        var src : Array<Int> = new Array<Int>();
        var dest : Array<Int> = new Array<Int>();
        var v : Int;
        for (i in 0...len) {
            v = isrc[i];
            if (in_dest.exists(v)) src.push(v);
        }
        for (i in 0...len2) {
            v = idest[i];
            if (in_src.exists(v)) dest.push(v);
        }

        return moveWithoutExtras(src,dest);
    }

    static private function moveWithoutExtras(src: Array<Int>, dest: Array<Int>) : Array<Int> {
        if (src.length!=dest.length) return null;
        if (src.length<=1) return [];
        
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
        var blk : Int = -1;
        var v : Int;
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
        blks.sort(function(a,b) { 
                var diff = blk_len.get(b)-blk_len.get(a);
                if (diff==0) diff=a-b;
                return diff;
            });

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
