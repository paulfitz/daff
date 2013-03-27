// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

interface Bag extends Datum {
    var size(get_size,never) : Int; // Read-only width property
    function getItem(x: Int) : Datum;
    function getItemView() : View;
}
