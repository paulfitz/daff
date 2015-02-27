// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * The row/column number for related content in the local table,
 * the remote table, and the parent table (if there is one).
 *
 */
class Unit {
    /**
     *
     * The row/column number in the local table.
     *
     */
    public var l : Int;

    /**
     *
     * The row/column number in the remote table.
     *
     */
    public var r : Int;

    /**
     *
     * The row/column number in the parent table.
     *
     */
    public var p : Int;

    /**
     *
     * Constructor.
     * @param l the row/column number in the local table (-1 means absent)
     * @param r the row/column number in the remote table (-1 means absent)
     * @param p the row/column number in the parent table (-1 means absent, -2 means there is no parent)
     *
     */
    public function new(l: Int = -2, r: Int = -2, p: Int = -2) : Void {
        this.l = l;
        this.r = r;
        this.p = p;
    }

    /**
     *
     * @return the row/column number in the parent table if present, otherwise in the local table
     *
     */
    public function lp() : Int {
        return (p==-2) ? l : p;
    } 
    

    private static function describe(i: Int) : String {
        return (i>=0) ? ("" + i) : "-";
    }

    /**
     *
     * @return a text serialization of the row/column numbers, as `LL:RR` when the parent is absent, and `PP|LL:RR` when the parent is present
     *
     */
    public function toString() : String {
        if (p>=-1) return describe(p) + "|" + describe(l) + ":" + describe(r);
        return describe(l) + ":" + describe(r);
    }

    /**
     *
     * Read from a serialized version of the row/column numbers
     * @param txt the string to read
     * @return true on success
     *
     */
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

    private function base26(num: Int) : String {
        // thanks @jordigh
        var alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        if (num<0) return "-";
        var out = "";
        do {
            out = out + alpha.charAt(num % 26);
            num = Math.floor(num / 26) - 1;
        } while (num>=0);
        return out;
    }

    /**
     *
     * @return as for toString(), but representing row/column numbers
     * as A,B,C,D,...,AA,AB,AC,AD,....
     *
     */
    public function toBase26String() : String {
        if (p>=-1) return base26(p) + "|" + base26(l) + ":" + base26(r);
        return base26(l) + ":" + base26(r);
    }
}
