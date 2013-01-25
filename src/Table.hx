// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

interface Table {
    var height(get_height,never) : Int; // Read-only height property
    var width(get_width,never) : Int; // Read-only width property
    function get_cell(x: Int, y: Int) : Cell;
    function set_cell(x: Int, y: Int, c : Cell) : Cell;
}
