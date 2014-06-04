// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

class SimpleCell {
    private var datum : Dynamic;

    public function new(x: Dynamic) {
        datum = x;
    }
    public function toString() : String {
        return datum;
    }
}
