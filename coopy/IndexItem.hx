// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:noDoc
class IndexItem {
    public var lst : Array<Int>;

    public function new() : Void {
    }

    public inline function add(i: Int) : Int {
        if (lst==null) lst = new Array<Int>();
        lst.push(i);
        return lst.length;
    }

    public inline function length() : Int {
        return lst.length;
    }

    public inline function value() : Int {
        return lst[0];
    }
}
