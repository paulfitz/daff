// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

// Optimize access to arrays of primitives, avoid needing 
// each item to be wrapped individually in some kind of access object.
// Anticipate future optimization with view pools.
interface View {
    function toString(d: Dynamic) : String;
    function getBag(d: Dynamic) : Bag;
    function getTable(d: Dynamic) : Table;
    function hasStructure(d: Dynamic) : Bool;
    function equals(d1: Dynamic, d2: Dynamic) : Bool;
    function toDatum(str: String) : Dynamic;
}
