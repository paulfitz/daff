// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

interface Table {
    var height(get_height,never) : Int; // Read-only height property
    var width(get_width,never) : Int;   // Read-only width property

    function getCell(x: Int, y: Int) : Dynamic;
    function setCell(x: Int, y: Int, c : Dynamic) : Void;
    function getCellView() : View;

    function isResizable() : Bool;
    function resize(w: Int, h: Int) : Bool;
    function clear() : Void;

    function insertOrDeleteRows(fate: Array<Int>, hfate: Int) : Bool;
    function insertOrDeleteColumns(fate: Array<Int>, wfate: Int) : Bool;

    function trimBlank() : Bool;

    // sorry for the inconsistent naming, this isn't needed anymore
    function get_width() : Int;
    function get_height() : Int;

    function getData() : Dynamic;
}
