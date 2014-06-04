// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

class Workspace {
    public var parent: ViewedDatum;
    public var local: ViewedDatum;
    public var remote: ViewedDatum;
    public var report: Report;

    public var tparent : Table;
    public var tlocal : Table;
    public var tremote : Table;

    public var p2l : TableComparisonState;
    public var p2r : TableComparisonState;
    public var l2r : TableComparisonState;

    public function new() : Void {
    }
}

