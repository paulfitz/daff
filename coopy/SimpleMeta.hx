// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * This implementation is unoptimized, it is expected to be replace with a native class.
 *
 */
@:expose
class SimpleMeta implements Meta {
    private var t : Table;
    private var name2row : Map<String,Int>;
    private var name2col : Map<String,Int>;
    private var has_properties : Bool;
    private var metadata : Map<String,Map<String,Dynamic>>;
    private var keys : Map<String,Bool>;
    private var row_active : Bool;
    private var row_change_cache : Array<RowChange>;
    private var may_be_nested : Bool;

    public function new(t: Table, has_properties: Bool = true,
                        may_be_nested : Bool = false) {
        this.t = t;
        rowChange();
        colChange();
        this.has_properties = has_properties;
        this.may_be_nested = may_be_nested;
        this.metadata = null;
        this.keys = null;
        row_active = false;
        row_change_cache = null;
    }

    /**
     *
     * This sneaky method will divert any row-level modifications
     * made during patching to a user-supplied array.
     *
     */
    public function storeRowChanges(changes : Array<RowChange>) {
        row_change_cache = changes;
        row_active = true;
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

    public function alterColumns(columns : Array<ColumnChange>) : Bool {
        var target = new Map<String,Int>();
        var wfate = 0;
        if (has_properties) {
            target.set("@",wfate);
            wfate++;
        }
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
        var start = has_properties ? 1 : 0;
        var at = start;
        for (i in 0...(columns.length)) {
            var col = columns[i];
            if (col.name!=null) {
                if (col.name!=col.prevName) {
                    t.setCell(at,0,col.name);
                }
            }
            if (col.name!=null) at++;
        }
        if (!has_properties) return true;
        colChange();
        at = start;
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

    private function setCell(c: String, r: String, val: Dynamic) : Bool {
        var ri = row(r);
        if (ri==-1) return false;
        var ci = col(c);
        if (ci==-1) return false;
        t.setCell(ci,ri,val);
        return true;
    }

    public function addMetaData(column: String, property: String, val: Dynamic) {
        if (metadata == null) {
            metadata = new Map<String,Map<String,Dynamic>>();
            keys = new Map<String,Bool>();
        }
        if (!metadata.exists(column)) {
            metadata.set(column,new Map<String,Dynamic>());
        }
        var props = metadata.get(column);
        props.set(property,val);
        keys.set(property,true);
    }

    public function asTable() : Table {
        if (has_properties && metadata==null) return t;
        if (metadata==null) return null;
        var w = t.width;
        var props = new Array<String>();
        for (k in keys.keys()) { props.push(k); }
        props.sort(Reflect.compare);
        var mt = new SimpleTable(w+1,props.length+1);
        mt.setCell(0,0,"@");
        for (x in 0...w) {
            var name = t.getCell(x,0);
            mt.setCell(1+x,0,name);
            if (!metadata.exists(name)) continue;
            var vals = metadata.get(name);
            for (i in 0...(props.length)) {
                if (vals.exists(props[i])) {
                    mt.setCell(1+x,i+1,vals.get(props[i]));
                }
            }
        }
        for (y in 0...(props.length)) {
            mt.setCell(0,y+1,props[y]);
        }
        return mt;
    }

    public function cloneMeta(table: Table = null) : Meta {
        var result = new SimpleMeta(table);
        if (metadata!=null) {
            result.keys = new Map<String,Bool>();
            for (k in keys.keys()) { result.keys.set(k,true); }
            result.metadata = new Map<String,Map<String,Dynamic>>();
            for (k in metadata.keys()) {
                if (!metadata.exists(k)) continue;
                var vals = metadata.get(k);
                var nvals = new Map<String,Dynamic>();
                for (p in vals.keys()) {
                    nvals.set(p,vals.get(p));
                }
                result.metadata.set(k,nvals);
            }
        }
        return result;
    }

    public function useForColumnChanges() : Bool {
        return true;
    }

    public function useForRowChanges() : Bool {
        return row_active;
    }

    public function changeRow(rc: RowChange) : Bool {
        row_change_cache.push(rc);
        return false;
    }

    public function applyFlags(flags: CompareFlags) : Bool {
        return false;
    }

    public function getRowStream() : RowStream {
        return new TableStream(t);
    }

    public function isNested() : Bool {
        return may_be_nested;
    }

    public function isSql() : Bool {
        return false;
    }

    public function getName() : String {
        return null;
    }
}

