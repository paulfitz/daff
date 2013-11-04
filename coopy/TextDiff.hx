// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

class TextDiff {
    public function new() {
    }

    // This is a placeholder for an implementation of Myers
    // (or just use Neil Fraser's diff code)
    public function find_longest_common_string(ls:String, rs:String) : TextOverlap {
        if (ls==rs) {
            return new TextOverlap(ls,0,0);
        }
        var nls : Int = ls.length;
        var nrs : Int = rs.length;
        var ns : Int = 1 + ((nls<nrs) ? nls : nrs);
        var lactive : Map<Int,String> = new Map<Int,String>();
        var ractive : Map<Int,String> = new Map<Int,String>();
        for (i in 0...ls.length) {
            lactive.set(i,"");
        }
        for (i in 0...rs.length) {
            ractive.set(i,"");
        }
        var winner : TextOverlap = new TextOverlap("",0,0);
        for (len in 1...ns) {
            var lpresent : Map<String,Int> = new Map<String,Int>();
            var rpresent : Map<String,Int> = new Map<String,Int>();
            var ct : Int = 0;
            for (l in lactive.keys()) {
                ct++;
                var s : String = lactive[l];
                s += ls.charAt(l-1+len);
                lactive[l] = s;
                if (s.length==len) lpresent.set(s,l);
            }
            if (ct==0) break;
            var drops : Array<Int> = new Array<Int>();
            for (r in ractive.keys()) {
                var s : String = ractive[r];
                s += rs.charAt(r-1+len);
                ractive[r] = s;
                if (!lpresent.exists(s)) {
                    drops.push(r);
                } else {
                    if (s.length==len) rpresent.set(s,r);
                }
            }
            for (d in drops) {
                ractive.remove(d);
            }
            drops = new Array<Int>();
            for (l in lactive.keys()) {
                var s : String = lactive[l];
                if (!rpresent.exists(s)) {
                    drops.push(l);
                } else {
                    winner.l = l;
                    winner.r = rpresent[s];
                    winner.text = s;
                }
            }
            for (d in drops) {
                lactive.remove(d);
            }
        }
        return winner;
    }

    public function diff(ls:String, rs:String) : Array<TextOverlap> {
        var diffs : Array<TextOverlap> = new Array<TextOverlap>();
        if (ls.length==0) {
            if (rs.length>0) {
                diffs.push(new TextOverlap(rs,-1,0));
            }
            return diffs;
        } else {
            if (rs.length==0) {
                diffs.push(new TextOverlap(ls,0,-1));
                return diffs;
            }
        }
        var overlap : TextOverlap = find_longest_common_string(ls,rs);
        var theta : Float = Math.min(ls.length,rs.length);
        theta /= 4;
        theta = Math.min(theta,5);
        theta = Math.max(1,theta);
        theta += 0.001;
        if (overlap.text.length<=theta) {
            diffs.push(new TextOverlap(ls,0,-1));
            diffs.push(new TextOverlap(rs,-1,0));
            return diffs;
        }
        diffs.push(overlap);

        var ls0 : String = ls.substr(0,overlap.l);
        var rs0 : String = rs.substr(0,overlap.r);
        var ls1 : String = ls.substr(overlap.l+overlap.text.length,ls.length);
        var rs1 : String = rs.substr(overlap.r+overlap.text.length,rs.length);
        var diff0 : Array<TextOverlap> = diff(ls0,rs0);
        var diff1 : Array<TextOverlap> = diff(ls1,rs1);
        if (diff0.length>0) {
            diffs = diff0.concat(diffs);
        }
        if (diff1.length>0) {
            diffs = diffs.concat(diff1);
        }
        return diffs;
    }
}
