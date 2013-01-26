// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class SimpleTable implements Table, implements Bag {
    private var data : IntHash<Datum>;
    private var w : Int;
    private var h : Int;

    public var bag : Bag;

    public function new(w: Int, h: Int) : Void {
        data = new IntHash<Datum>();
        this.w = w;
        this.h = h;
        bag = this;
    }

    public function get_table() : Table {
        return this;
    }

    public var height(get_height,never) : Int;
    public var width(get_width,never) : Int;
    public var size(get_size,never) : Int;

    private function get_width() : Int {
        return w;
    }

    private function get_height() : Int {
        return h;
    }

    private function get_size() : Int {
        return h;
    }

    public function get_cell(x: Int, y: Int) : Datum {
        return data.get(x+y*w);
    }

    public function set_cell(x: Int, y: Int, c: Datum) : Datum {
        data.set(x+y*w,c);
        return c;
    }

    public function get_item(y: Int) : Datum {
        return new SimpleRow(this,y);
    }

    public function toString() : String {
        var x : String = "";
        for (i in 0...height) {
            x += get_item(i);
            x += "\n";
        }
        return x;
    }
}
