// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class TableText {
    private var rows : Table;
    private var view : View;

    public function new(rows: Table) : Void {
        this.rows = rows;
        this.view = rows.getCellView();
    }

    public function getCellText(x: Int, y: Int) : String {
        return view.toString(rows.getCell(x,y));
    }
}
