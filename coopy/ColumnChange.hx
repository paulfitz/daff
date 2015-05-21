// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

class ColumnChange {
    public var prevName : String;
    public var name : String;
    public var props : Array<PropertyChange>;

    public function new() {}
}
