// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

interface Table {
    var height(get_height,never) : Int; // Read-only height property
    var width(get_width,never) : Int; // Read-only width property
    function getCell(x: Int, y: Int) : Datum;
    function setCell(x: Int, y: Int, c : Datum) : Void;
    function getCellView() : View;

    function isResizable() : Bool;
    function resize(w: Int, h: Int) : Bool;
    function clear() : Void;
}
