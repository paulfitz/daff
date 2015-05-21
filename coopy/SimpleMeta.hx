// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * This implementation is unoptimized, it is expected to be replace with a native class.
 *
 */
class SimpleMeta implements Meta {
    private var t : Table;
    private var name2row : Map<String,Int>;
    private var name2col : Map<String,Int>;

    public function new(t: Table) {
        this.t = t;
        rowChange();
        colChange();
    }

    private function rowChange() {
        name2row = null;
    }

    private function colChange() {
        name2col = null;
    }

    private function col(key: String) : Int {
        if (t.height<1) return -1;
        if (name2col==null) {
            name2col = new Map<String,Int>();
            var w = t.width;
            for (c in 0...w) {
                name2col.set(t.getCell(c,0),c);
            }
        }
        if (!name2col.exists(key)) return -1;
        return name2col.get(key);
    }

    private function row(key: String) : Int {
        if (t.width<1) return -1;
        if (name2row==null) {
            name2row = new Map<String,Int>();
            var h = t.height;
            for (r in 1...h) {
                name2row.set(t.getCell(0,r),r);
            }
        }
        if (!name2row.exists(key)) return -1;
        return name2row.get(key);
    }

    public function asTable() : Table {
        return t;
    }

    public function canEditAsTable() : Bool {
        return true;
    }

    public function alterColumns(columns : Array<ColumnChange>) : Bool {
        var target = new Map<String,Int>();
        var wfate = 0;
        target.set("@",wfate);
        wfate++;
        for (i in 0...(columns.length)) {
            var col = columns[i];
            if (col.prevName!=null) {
                target.set(col.prevName,wfate);
            }
            if (col.name!=null) wfate++;
        }
        var fate = new Array<Int>();
        for (i in 0...(t.width)) {
            var targeti = -1;
            var name = t.getCell(i,0);
            if (target.exists(name)) {
                targeti = target.get(name);
            }
            fate.push(targeti);
        }
        t.insertOrDeleteColumns(fate,wfate);
        var at = 1;
        for (i in 0...(columns.length)) {
            var col = columns[i];
            if (col.name!=null) {
                if (col.name!=col.prevName) {
                    t.setCell(at,0,col.name);
                }
            }
            if (col.name!=null) at++;
        }
        colChange();
        at = 1;
        for (i in 0...(columns.length)) {
            var col = columns[i];
            if (col.name!=null) {
                for (prop in col.props) {
                    setCell(col.name,prop.name,prop.val);
                }
            }
            if (col.name!=null) at++;
        }
        return true;
    }

    public function addColumn(key: String, vals: Map<String,Dynamic>, idx: Int = -1) : Bool {
        colChange();
        var d0 = t.width;
        var d1 = t.height;
        var fate = new Array<Int>();
        if (idx==-1) idx = d0;
        for (d in 0...d0) {
            fate.push(d+((d>=idx)?1:0));
        }
        if (!t.insertOrDeleteColumns(fate,d0+1)) return false;
        t.setCell(idx,0,key);
        for (d in 1...d1) {
            var k = t.getCell(0,d);
            if (vals.exists(k)) {
                t.setCell(idx,d,vals.get(k));
            }
        }
        return true;
    }

    public function removeColumn(key: String) : Bool {
        var d0 = t.width;
        var idx = col(key);
        if (idx==-1) return false;
        colChange();
        var fate = new Array<Int>();
        for (d in 0...d0) {
            if (idx==d) {
                fate.push(-1);
            } else {
                fate.push(d-((d>=idx)?1:0));
            }
        }
        return t.insertOrDeleteColumns(fate,d0-1);
    }

    public function renameColumn(prev: String, next: String) : Bool {
        var d1 = t.height;
        var idx = col(prev);
        if (idx==-1) return false;
        if (d1<1) return false;
        colChange();
        t.setCell(idx,0,next);
        return true;
    }

    public function moveColumn(key: String, idx : Int) : Bool {
        var d0 = t.width;
        var idx2 = col(key);
        if (idx2==-1) return false;
        colChange();
        if (idx==-1) idx = d0-1;
        var fate = new Array<Int>();
        for (d in 0...d0) {
            var target = d;
            if (d>=idx2) target--;
            if (d>=idx) target++;
            if (d==idx2) target = idx;
            fate.push(target);
        }
        return t.insertOrDeleteColumns(fate,d0);
    }

    public function addRow(key: String, vals: Map<String,Dynamic>, idx : Int = -1) : Bool {
        rowChange();
        var d1 = t.width;
        var d0 = t.height;
        var fate = new Array<Int>();
        if (idx==-1) idx = d0;
        for (d in 0...d0) {
            fate.push(d+((d>=idx)?1:0));
        }
        if (!t.insertOrDeleteRows(fate,d0+1)) return false;
        t.setCell(0,idx,key);
        for (d in 1...d1) {
            var k = t.getCell(d,0);
            if (vals.exists(k)) {
                t.setCell(d,idx,vals.get(k));
            }
        }
        return true;
    }

    public function removeRow(key: String) : Bool {
        var d0 = t.height;
        var idx = row(key);
        if (idx==-1) return false;
        rowChange();
        var fate = new Array<Int>();
        for (d in 0...d0) {
            if (idx==d) {
                fate.push(-1);
            } else {
                fate.push(d-((d>=idx)?1:0));
            }
        }
        return t.insertOrDeleteRows(fate,d0-1);
    }

    public function renameRow(prev: String, next: String) : Bool {
        var d1 = t.width;
        var idx = row(prev);
        if (idx==-1) return false;
        if (d1<1) return false;
        rowChange();
        t.setCell(0,idx,next);
        return true;
    }

    public function moveRow(key: String, idx : Int) : Bool {
        var d0 = t.height;
        var idx2 = row(key);
        if (idx2==-1) return false;
        rowChange();
        if (idx==-1) idx = d0-1;
        var fate = new Array<Int>();
        for (d in 0...d0) {
            var target = d;
            if (d>=idx2) target--;
            if (d>=idx) target++;
            if (d==idx2) target = idx;
            fate.push(target);
        }
        return t.insertOrDeleteRows(fate,d0);
    }

    public function setCell(c: String, r: String, val: Dynamic) : Bool {
        var ri = row(r);
        if (ri==-1) return false;
        var ci = col(c);
        if (ci==-1) return false;
        t.setCell(ci,ri,val);
        return true;
    }
}
