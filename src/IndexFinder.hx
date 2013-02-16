// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class IndexFinder {
    public var a: Table;
    public var b: Table;

    public var apending : IntHash<Int>;
    public var bpending : IntHash<Int>;

    public var cross : Hash<CrossIndexItem>;
    public var count : Hash<Int>;

    public var view : View;
    public var active_key : String;

    public function new(a: Table, b: Table) : Void {
        this.a = a;
        this.b = b;
        view = a.getCellView();
        apending = new IntHash<Int>();
        bpending = new IntHash<Int>();
        var ha : Int = a.height;
        var hb : Int = b.height;
        for (i in 0...ha) {
            apending.set(i,i);
        }
        for (i in 0...hb) {
            bpending.set(i,i);
        }
        cross = new Hash<CrossIndexItem>();
        count = new Hash<Int>();
        scan();
    }

    public function makeKey(i: Int, d: Datum) : String {
        return view.toString(d) + " " + i;
    }

    public function makeCountKey(xa: Int, xb: Int) : String {
        return "" + xa + " " + xb;
    }

    public function scan() : Void {
        var ha : Int = a.height;
        var hb : Int = b.height;
        for (i in 0...ha) {
            for (j in 0...a.width) {
                var key: String = makeKey(j,a.getCell(j,i));
                var item: CrossIndexItem = cross.get(key);
                if (item==null) {
                    item = new CrossIndexItem();
                    cross.set(key,item);
                }
                item.act++;
                if (item.as==null) item.as = new IntHash<Int>();
                item.as.set(i,1);
            }
        }
        for (i in 0...hb) {
            for (j in 0...b.width) {
                var key: String = makeKey(j,b.getCell(j,i));
                var item: CrossIndexItem = cross.get(key);
                if (item==null) {
                    item = new CrossIndexItem();
                    cross.set(key,item);
                }
                item.bct++;
                if (item.bs==null) item.bs = new IntHash<Int>();
                item.bs.set(i,1);
            }
        }
        var pending : Array<String> = new Array<String>();
        for (k in cross.keys()) {
            var item: CrossIndexItem = cross.get(k);
            if (item.act<=0 || item.bct<=0) {
                pending.push(k);
            }
        }
        for (k in pending) {
            cross.remove(k);
        }
    }

    public function retireRow(xa: Int, xb: Int) : Void {
        for (j in 0...a.width) {
            var key: String = makeKey(j,a.getCell(j,xa));
            var item: CrossIndexItem = cross.get(key);
            if (item==null) continue;
            if (item.act>0) {
                item.as.remove(xa);
            }
            item.act--;
            if (item.act<=0 || item.bct<=0) {
                cross.remove(key);
            }
        }
        for (j in 0...b.width) {
            var key: String = makeKey(j,b.getCell(j,xb));
            var item: CrossIndexItem = cross.get(key);
            if (item==null) continue;
            if (item.bct>0) {
                item.bs.remove(xb);
            }
            item.bct--;
            if (item.act<=0 || item.bct<=0) {
                cross.remove(key);
            }
        }
    }

    public function getNext() : CrossIndexItem {
        if (active_key!=null) {
            cross.remove(active_key);
        }
        active_key = cross.keys().next();
        if (active_key==null) return null;
        return cross.get(active_key);
    }
}
