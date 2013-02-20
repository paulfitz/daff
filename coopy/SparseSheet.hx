// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

class SparseSheet<T> {
    private var h : Int;
    private var w : Int;
    private var row : IntHash<IntHash<T>>;
    private var zero : T;

    public function new() : Void {
        h = w = 0;
    }

    public function resize(w: Int, h: Int, zero: T) : Void {
        row = new IntHash<IntHash<T>>();
        nonDestructiveResize(w,h,zero);
    }

    public function nonDestructiveResize(w: Int, h: Int, zero: T) : Void {
        this.w = w;
        this.h = h;
        this.zero = zero;
    }

    public function get(x: Int, y: Int) : T {
        var cursor : IntHash<T> = row.get(y);
        if (cursor==null) return zero;
        var val : Null<T> = cursor.get(x);
        if (val==null) return zero;
        return val;
    }
    
    public function set(x: Int, y: Int, val: T) : Void {
        var cursor : IntHash<T> = row.get(y);
        if (cursor==null) {
            cursor = new IntHash<T>();
            row.set(y,cursor);
        }
        cursor.set(x,val);
    }
}
