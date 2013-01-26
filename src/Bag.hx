// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

interface Bag implements Datum {
    var size(get_size,never) : Int; // Read-only width property
    function get_item(x: Int) : Datum;
    function get_table() : Table;
}
