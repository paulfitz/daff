// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:noDoc
class SparseSheet<T> {
    private var h : Int;
    private var w : Int;
    private var row : Map<Int,Map<Int,T>>;
    private var zero : T;

    public function new() : Void {
        h = w = 0;
    }

    public function resize(w: Int, h: Int, zero: T) : Void {
        row = new Map<Int,Map<Int,T>>();
        nonDestructiveResize(w,h,zero);
    }

    public function nonDestructiveResize(w: Int, h: Int, zero: T) : Void {
        this.w = w;
        this.h = h;
        this.zero = zero;
    }

    public function get(x: Int, y: Int) : T {
        var cursor : Map<Int,T> = row.get(y);
        if (cursor==null) return zero;
        var val : Null<T> = cursor.get(x);
        if (val==null) return zero;
        return val;
    }
    
    public function set(x: Int, y: Int, val: T) : Void {
        var cursor : Map<Int,T> = row.get(y);
        if (cursor==null) {
            cursor = new Map<Int,T>();
            row.set(y,cursor);
        }
        cursor.set(x,val);
    }
}
