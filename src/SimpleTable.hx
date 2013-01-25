// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class SimpleTable implements Table {
    private var data : IntHash<Cell>;
    private var w : Int;
    private var h : Int;

    public function new(w: Int, h: Int) : Void {
        data = new IntHash<Cell>();
        this.w = w;
        this.h = h;
    }

    public var height(get_height,never) : Int;
    public var width(get_width,never) : Int;

    private function get_width() : Int {
        return w;
    }

    private function get_height() : Int {
        return h;
    }

    public function get_cell(x: Int, y: Int) : Cell {
        return data.get(x+y*w);
    }

    public function set_cell(x: Int, y: Int, c: Cell) : Cell {
        data.set(x+y*w,c);
        return c;
    }
}
