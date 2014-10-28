// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
@:noDoc
class TableModifier {
    private var t : Table;

    public function new(t: Table) : Void {
        this.t = t;
    }

    public function removeColumn(at: Int) : Bool {
        var fate : Array<Int> = [];
        for (i in 0...t.width) {
            if (i<at) {
                fate.push(i);
            } else if (i>at) {
                fate.push(i-1);
            } else {
                fate.push(-1);
            }
        }
        return t.insertOrDeleteColumns(fate,t.width-1);
    }
}
