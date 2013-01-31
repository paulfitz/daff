// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class Workspace {
    public var parent: ViewedDatum;
    public var local: ViewedDatum;
    public var remote: ViewedDatum;
    public var report: Report;

    public var tparent : Table;
    public var tlocal : Table;
    public var tremote : Table;

    public var p2l : Comparison;
    public var p2r : Comparison;
    public var l2r : Comparison;

    public function new() : Void {
    }
}

