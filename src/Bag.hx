// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

interface Bag implements Datum {
    var size(getSize,never) : Int; // Read-only width property
    function getItem(x: Int) : Datum;
    function getItemView() : View;
}
