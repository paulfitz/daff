// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Experimental wrapper for reading tables expressed as json in following
 * format:
 *
 * {
 *   "names": ["sheet1", "sheet2"],
 *   "tables": {
 *     "sheet1": {
 *        "columns": ["col1", "col2", "col3"],
 *        "rows": [
 *            { "col1": 42, "col2": "x", "col3": null },
 *            { "col1": 24, "col2": "y", "col3": null },
 *            ...
 *        ]
 *     },
 *     "sheet2": {
 *        ...
 *     }
 *   }
 * }
 *
 *
 */
class JsonTables implements Table {
    private var db: Dynamic;
    private var t: Table;
    private var flags: CompareFlags;

    public function new(json: Dynamic, flags: CompareFlags) {
        this.db = json;
        var names : Array<String> = Reflect.field(json, "names");
        var allowed : Map<String,Bool> = null;
        var count : Int = names.length;
        if (flags!=null && flags.tables!=null) {
            allowed = new Map<String,Bool>();
            for (name in flags.tables) {
                allowed.set(name,true);
            }
            count = 0;
            for (name in names) {
                if (allowed.exists(name)) {
                    count++;
                }
            }
        }
        t = new SimpleTable(2,count+1);
        t.setCell(0,0,"name");
        t.setCell(1,0,"table");
        var v = t.getCellView();
        var at = 1;
        for (name in names) {
            if (allowed!=null) {
                if (!allowed.exists(name)) continue;
            }
            t.setCell(0,at,name);
            var tab = Reflect.field(db, "tables");
            tab = Reflect.field(tab, name);
            t.setCell(1,at,v.wrapTable(new JsonTable(tab, name)));
            at++;
        }
    }

    public var height(get,never) : Int;
    public var width(get,never) : Int;

    public function getCell(x: Int, y: Int) : Dynamic {
        return t.getCell(x,y);
    }

    public function setCell(x: Int, y: Int, c : Dynamic) : Void {
    }

    public function getCellView() : View {
        return t.getCellView();
    }

    public function isResizable() : Bool {
        return false;
    }

    public function resize(w: Int, h: Int) : Bool {
        return false;
    }

    public function clear() : Void {
    }

    public function insertOrDeleteRows(fate: Array<Int>, hfate: Int) : Bool {
        return false;
    }

    public function insertOrDeleteColumns(fate: Array<Int>, wfate: Int) : Bool {
        return false;
    }

    public function trimBlank() : Bool {
        return false;
    }

    public function get_width() : Int {
        return t.width;
    }

    public function get_height() : Int {
        return t.height;
    }

    public function getData() : Dynamic {
        return null;
    }

    public function clone() : Table {
        return null;
    }

    public function getMeta() : Meta {
        return new SimpleMeta(this,true,true);
    }

    public function create() : Table {
        return null;
    }
}
