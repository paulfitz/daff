// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

// Constrained to be almost nothing, so that it can be 
// safely have built-in types substituted in javascript etc.
interface Datum {
    function toString() : String;
}
