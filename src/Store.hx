// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

// Just a test if we can easily swap in external javascript objects
// without bureaucracy

#if (js)
extern 
#end
class Store {
#if (js)
    function new() : Void;
#else
    public function new() : Void {}
#end
    public var frog : String;
    public var fish : String;
    public var pond : String;
    public var scum : Int;
}
