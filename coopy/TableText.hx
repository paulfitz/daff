// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * View all cells of a table as text.
 *
 */
@:expose
class TableText {
    private var tab : Table;
    private var view : View;

    
    /**
     *
     * Constructor.
     * @param tab the table to wrap
     *
     */
    public function new(tab: Table) : Void {
        this.tab = tab;
        this.view = tab.getCellView();
    }

    /**
     *
     * Read a cell in the table as text.
     * @param x the column to read from
     * @param y the row to read from
     * @return the specified cell, converted to text
     *
     */
    public function getCellText(x: Int, y: Int) : String {
        return view.toString(tab.getCell(x,y));
    }
}
