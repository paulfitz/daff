// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

// Optimize access to arrays of primitives, avoid needing 
// each item to be wrapped individually in some kind of access object.
// Anticipate future optimization with view pools.
interface View {
    function toString(d: Datum) : String;
    function getBag(d: Datum) : Bag;
    function getTable(d: Datum) : Table;
    function hasStructure(d: Datum) : Bool;
    function equals(d1: Datum, d2: Datum) : Bool;
}
