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

    public function getTable() : Table {
        return this;
    }

    public var height(getHeight,never) : Int;
    public var width(getWidth,never) : Int;
    public var size(getSize,never) : Int;

    private function getWidth() : Int {
        return w;
    }

    private function getHeight() : Int {
        return h;
    }

    private function getSize() : Int {
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
}
