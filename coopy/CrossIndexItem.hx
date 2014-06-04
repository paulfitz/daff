// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

class CrossIndexItem {
    public var act : Int;
    public var bct : Int;
    public var as : Map<Int,Int>;
    public var bs : Map<Int,Int>;

    public function new() : Void {
        act = 0;
        bct = 0;
    }
}
