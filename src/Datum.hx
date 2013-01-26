// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

// Constrained to be almost nothing, so that it can be 
// safely have built-in types substituted in javascript etc.
// Keep all fancy stuff to Bag.
interface Datum {
    function toString() : String;
    var bag : Bag;
}
