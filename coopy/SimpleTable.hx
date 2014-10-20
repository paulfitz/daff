// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class SimpleTable implements Table {
    private var data : Map<Int,Dynamic>;
    private var w : Int;
    private var h : Int;

    public function new(w: Int, h: Int) : Void {
        data = new Map<Int,Dynamic>();
        this.w = w;
        this.h = h;
    }

    public function getTable() : Table {
        return this;
    }

    public var height(get_height,never) : Int;
    public var width(get_width,never) : Int;
    public var size(get_size,never) : Int;

    public function get_width() : Int {
        return w;
    }

    public function get_height() : Int {
        return h;
    }

    private function get_size() : Int {
        return h;
    }

    public function getCell(x: Int, y: Int) : Dynamic {
        return data.get(x+y*w);
    }

    public function setCell(x: Int, y: Int, c: Dynamic) : Void {
        data.set(x+y*w,c);
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

    public function isResizable() : Bool {
        return true;
    }

    public function resize(w: Int, h: Int) : Bool {
        this.w = w;
        this.h = h;
        return true;
    }

    public function clear() : Void {
        data = new Map<Int,Dynamic>();
    }

    public function insertOrDeleteRows(fate: Array<Int>, hfate: Int) : Bool {
        var data2 : Map<Int,Dynamic> = new Map<Int,Dynamic>();
        for (i in 0...fate.length) {
            var j : Int = fate[i];
            if (j!=-1) {
                for (c in 0...w) {
                    var idx : Int = i*w+c;
                    if (data.exists(idx)) {
                        data2.set(j*w+c,data.get(idx));
                    }
                }
            }
        }
        h = hfate;
        data = data2;
        return true;
    }

    public function insertOrDeleteColumns(fate: Array<Int>, wfate: Int) : Bool {
        var data2 : Map<Int,Dynamic> = new Map<Int,Dynamic>();
        for (i in 0...fate.length) {
            var j : Int = fate[i];
            if (j!=-1) {
                for (r in 0...h) {
                    var idx : Int = r*w+i;
                    if (data.exists(idx)) {
                        data2.set(r*wfate+j,data.get(idx));
                    }
                }
            }
        }
        w = wfate;
        data = data2;
        return true;
    }

    public function trimBlank() : Bool {
        if (h==0) return true;
        var h_test : Int = h;
        if (h_test>=3) h_test = 3;
        var view : View = getCellView();
        var space : Dynamic = view.toDatum("");
        var more : Bool = true;
        while (more) {
            for (i in 0...width) {
                var c : Dynamic = getCell(i,h-1);
                if (!(view.equals(c,space)||c==null)) {
                    more = false;
                    break;
                }
            }
            if (more) h--;
        }
        more = true;
        var nw : Int = w;
        while (more) {
            if (w==0) break;
            for (i in 0...h_test) {
                var c : Dynamic = getCell(nw-1,i);
                if (!(view.equals(c,space)||c==null)) {
                    more = false;
                    break;
                }
            }
            if (more) nw--;
        }
        if (nw==w) return true;
        var data2 : Map<Int,Dynamic> = new Map<Int,Dynamic>();
        for (i in 0...nw) {
            for (r in 0...h) {
                var idx : Int = r*w+i;
                if (data.exists(idx)) {
                    data2.set(r*nw+i,data.get(idx));
                }
            }
        }
        w = nw;
        data = data2;
        return true;
    }

    public function getData() {
        return null;
    }
}
