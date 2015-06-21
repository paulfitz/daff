// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

class TableStream implements RowStream {
    private var t : Table;
    private var at : Int;
    private var h : Int;
    private var src : RowStream;
    private var columns : Array<String>;
    private var row : Map<String, Dynamic>;

    public function new(t: Table) {
        this.t = t;
        at = -1;
        h = t.height;
        src = null;
        if (h<0) {
            var meta = t.getMeta();
            if (meta==null) {
                throw("Cannot get meta information for table");
            }
            src = meta.getRowStream();
            if (src==null) {
                throw("Cannot iterate table");
            }
        }
    }

    public function fetchColumns() : Array<String> {
        if (columns!=null) return columns;
        if (src!=null) {
            columns = src.fetchColumns();
            return columns;
        }
        columns = new Array<String>();
        for (i in 0...t.width) {
            columns.push(t.getCell(i,0));
        }
        return columns;
    }

    public function fetchRow() : Map<String, Dynamic> {
        if (src!=null) return src.fetchRow();
        if (at>=h) return null;
        var row = new Map<String,Dynamic>();
        for (i in 0...columns.length) {
            row[columns[i]] = t.getCell(i,at);
        }
        return row;
    }

    public function fetch() : Bool {
        if (at==-1) {
            at++;
            if (src!=null) fetchColumns();
            return true;
        }
        if (src!=null) {
            at = 1;
            row = fetchRow();
            return row!=null;
        }
        at++;
        return at<h;
    }

    public function getCell(x: Int) : Dynamic {
        if (at==0) {
            return columns[x];
        }
        if (row!=null) {
            return row[columns[x]];
        }
        return t.getCell(x,at);
    }

    public function width() : Int {
        fetchColumns();
        return columns.length;
    }
}
