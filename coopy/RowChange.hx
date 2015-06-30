// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * A description of a row-level change to a table.
 *
 */
@:expose
class RowChange {
    public var cond : Map<String, Dynamic>;
    public var val : Map<String, Dynamic>;
    public var conflicting_val : Map<String, Dynamic>;
    public var conflicting_parent_val : Map<String, Dynamic>;
    public var conflicted: Bool;
    public var is_key : Map<String, Bool>;
    public var action : String;

    public function new() {
    }

    private function showMap(m: Map<String,Dynamic>) : String {
        if (m==null) return "{}";
        var txt = "";
        for (k in m.keys()) {
            if (txt!="") txt += ", ";
            var v = m.get(k);
            txt += k + "=" + v;
        }
        return "{ " + txt + " }";
    }

    public function toString() : String {
        return action + " " + showMap(cond) + " : " + showMap(val);
    }
}
