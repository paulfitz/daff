// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * A basic view implementation, for interpreting the content of cells. 
 * Each supported language may have an optimized native implementation.
 * See the `View` interface for documentation.
 *
 */
@:expose
class SimpleView implements View {
    public function new() : Void {
    }

    public function toString(d: Dynamic) : String {
        if (d==null) return "";
        return "" + d;
    }
    
    public function equals(d1: Dynamic, d2: Dynamic) : Bool {
        if (d1==null && d2==null) return true;
        if (d1==null || d2==null) return false;
        return ("" + d1) == ("" + d2);
    }

    public function toDatum(x: Dynamic) : Dynamic {
#if cpp
        return new SimpleCell(x);
#else
        return x;
#end
    }

    public function makeHash() : Dynamic {
        return new Map<String,Dynamic>();
    }

    public function hashSet(h: Dynamic, str: String, d: Dynamic) : Void {
        var hh : Map<String,Dynamic> = cast h;
        hh.set(str,d);
    }

    public function hashExists(h: Dynamic, str: String) : Bool {
        var hh : Map<String,Dynamic> = cast h;
        return hh.exists(str);
    }

    public function hashGet(h: Dynamic, str: String) : Dynamic {
        var hh : Map<String,Dynamic> = cast h;
        return hh.get(str);
    }

    public function isHash(h: Dynamic) : Bool {
#if rb
        // work around limitation of ruby target
        return untyped __rb__("h.respond_to? :keys");
#else
        return Std.is(h,haxe.ds.StringMap);
#end
    }

    public function isTable(t : Dynamic) : Bool {
        return Std.is(t,Table);
    }

    public function getTable(t : Dynamic) : Table {
        return cast t;
    }

    public function wrapTable(t : Table) : Dynamic {
        return t;
    }
}

