// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

class SimpleRow implements Bag {
    private var tab : Table;
    private var row_id : Int;

    public var bag : Bag;
    public function new(tab: Table, row_id: Int) {
        this.tab = tab;
        this.row_id = row_id;
        bag = this;
    }
    
    public var size(get_size,never) : Int;

    private function get_size() : Int {
        return tab.width;
    }
    
    public function getItem(x: Int) : Datum {
        return tab.getCell(x,row_id);
    }

    public function setItem(x: Int, c: Datum) : Void {
        tab.setCell(x,row_id,c);
    }    

    public function getTable() : Table {
        return null;
    }

    public function toString() : String {
        var x : String = "";
        for (i in 0...(tab.width)) {
            if (i>0) x += " ";
            x += getItem(i);
        }
        return x;
    }

    public function getItemView() : View {
        return new SimpleView();
    }
}
