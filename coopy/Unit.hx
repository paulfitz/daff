// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

class Unit {
    public var l : Int;
    public var r : Int;
    public var p : Int;

    public function new(l: Int = -2, r: Int = -2, p: Int = -2) : Void {
        this.l = l;
        this.r = r;
        this.p = p;
    }

    public function lp() : Int {
        return (p==-2) ? l : p;
    } 
    

    public static function describe(i: Int) : String {
        return (i>=0) ? ("" + i) : "-";
    }

    public function toString() : String {
        if (p>=-1) return describe(p) + "|" + describe(l) + ":" + describe(r);
        return describe(l) + ":" + describe(r);
    }

    public function fromString(txt: String) : Bool {
        txt += "]";
        var at : Int = 0;
        for (i in 0...txt.length) {
            var ch : Int = txt.charCodeAt(i);
            if (ch>='0'.code && ch<='9'.code) {
                at *= 10;
                at += ch - '0'.code;
            } else if (ch == '-'.code) {
                at = -1;
            } else if (ch == '|'.code) {
                p = at;
                at = 0;
            } else if (ch == ':'.code) {
                l = at;
                at = 0;
            } else if (ch == ']'.code) {
                r = at;
                return true;
            }
        }
        return false;
    }
}
