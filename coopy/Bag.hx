// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:noDoc
interface Bag {
    var size(get_size,never) : Int; // Read-only width property
    function getItem(x: Int) : Dynamic;
    function getItemView() : View;
}
