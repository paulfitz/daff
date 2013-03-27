// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class SimpleTable implements Table implements Bag {
    private var data : Map<Int,Datum>;
    private var w : Int;
    private var h : Int;

    public var bag : Bag;

    public function new(w: Int, h: Int) : Void {
        data = new Map<Int,Datum>();
        this.w = w;
        this.h = h;
        bag = this;
    }

    public function getTable() : Table {
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

    public function getCell(x: Int, y: Int) : Datum {
        return data.get(x+y*w);
    }

    public function setCell(x: Int, y: Int, c: Datum) : Void {
        data.set(x+y*w,c);
    }

    public function getItem(y: Int) : Datum {
        return new SimpleRow(this,y);
    }

    public function toString() : String {
        return tableToString(this);
    }
    
    public static function tableToString(tab : Table) : String {
        var x : String = "";
        for (i in 0...tab.height) {
            for (j in 0...tab.width) {
                if (j>0) x += " ";
                x += tab.getCell(j,i);
            }
            x += "\n";
        }
        return x;
    }
    
    public function getCellView() : View {
        return new SimpleView();
    }

    public function getItemView() : View {
        return new BagView();
    }

    public function isResizable() : Bool {
        return true;
    }

    public function resize(w: Int, h: Int) : Bool {
        this.w = w;
        this.h = h;
        return true;
    }


    public function clear() : Void {
        data = new Map<Int,Datum>();
    }
}
