// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

class Index {
    public var items : Map<String,IndexItem>;
    public var keys : Array<String>;
    public var top_freq : Int;
    public var height : Int;

    private var cols : Array<Int>;
    private var v : View;
    private var indexed_table : Table;

    public function new() : Void {
        items = new Map<String,IndexItem>();
        cols = new Array<Int>();
        keys = new Array<String>();
        top_freq = 0;
        height = 0;
    }
 
    public function addColumn(i: Int) : Void {
        cols.push(i);
    }

    public function indexTable(t: Table) : Void {
        indexed_table = t;
        for (i in 0...t.height) {
            var key : String;
            if (keys.length>i) {
                key = keys[i];
            } else {
                key = toKey(t,i);
                keys.push(key);
            }
            var item : IndexItem = items.get(key);
            if (item==null) {
                item = new IndexItem();
                items.set(key,item);
            }
            var ct : Int = item.add(i);
            if (ct>top_freq) top_freq = ct;
        }
        height = t.height;
    }

    public function toKey(t: Table, 
                          i: Int) : String {
        var wide : String = "";
        if (v==null) v = t.getCellView();
        for (k in 0...cols.length) {
            var d : Datum = t.getCell(cols[k],i);
            var txt : String = v.toString(d);
            if (txt=="" || txt=="null" || txt=="undefined") continue;
            if (k>0) wide += " // ";
            wide += txt;
        }
        return wide;
    }

    public function toKeyByContent(row: Row) : String {
        var wide : String = "";
        for (k in 0...cols.length) {
            var txt : String = row.getRowString(k);
            if (txt=="" || txt=="null" || txt=="undefined") continue;
            if (k>0) wide += " // ";
            wide += txt;
        }
        return wide;
    }

    public function getTable() : Table {
        return indexed_table;
    }
}
