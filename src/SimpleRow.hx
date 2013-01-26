// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class SimpleRow implements Bag, implements Datum {
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
    
    public function get_item(x: Int) : Datum {
        return tab.get_cell(x,row_id);
    }

    public function set_item(x: Int, c: Datum) : Datum {
        return tab.set_cell(x,row_id,c);
    }    

    public function get_table() : Table {
        return null;
    }

    public function toString() : String {
        var x : String = "";
        for (i in 0...(tab.width)) {
            if (i>0) x += " ";
            x += get_item(i);
        }
        return x;
    }
}
