// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

class ConflictInfo {
    public var row : Int;
    public var col : Int;
    public var pvalue : Dynamic;
    public var lvalue : Dynamic;
    public var rvalue : Dynamic;

    public function new(row: Int, col: Int, pvalue : Dynamic, lvalue : Dynamic, rvalue : Dynamic) : Void {
        this.row = row;
        this.col = col;
        this.pvalue = pvalue;
        this.lvalue = lvalue;
        this.rvalue = rvalue;
    }
}
