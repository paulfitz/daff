// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class HighlightPatch implements Row {
    private var source : Table;
    private var patch : Table;
    private var currentRow : Int;
    private var payloadCol : Int;
    private var payloadTop : Int;
    private var view : View;
    private var headerPre : Map<String,Int>;
    private var headerPost : Map<String,Int>;
    private var schemaModifier : Map<Int,String>;
    private var indexes : Array<IndexPair>;
    private var sourceInPatch : Map<Int,Int>;
    private var patchInSource2 : Map<Int,Int>;
    private var mods : Array<HighlightPatchUnit>;

    public function new(source: Table, patch: Table) {
        this.source = source;
        this.patch = patch;
        headerPre = new Map<String,Int>();
        headerPost = new Map<String,Int>();
        schemaModifier = new Map<Int,String>();
        sourceInPatch = new Map<Int,Int>();
        patchInSource2 = new Map<Int,Int>();
        mods = new Array<HighlightPatchUnit>();
    }

    public function apply() : Bool {
        if (patch.width<2) return true;
        for (r in 0...patch.height) {
            applyRow(r);
        }
        finish();
        return true;
    }

    private function needSourceIndex() : Void {
        if (indexes!=null) return;
        var state : TableComparisonState = new TableComparisonState();
        state.a = source;
        state.b = source;
        var comp : CompareTable = new CompareTable();
        comp.storeIndexes();
        comp.attach(state);
        comp.align();
        indexes = comp.getIndexes();
        // make sure we know where source columns are
        var av : View = source.getCellView();
        for (i in 0...source.width) {
            var name : String = av.toString(source.getCell(i,0));
            var at : Null<Int> = headerPre.get(name);
            if (at == null) continue;
            sourceInPatch.set(i,at);
            patchInSource2.set(at,i);  // needs tweak for add/rems
        }
    }

    private function applyRow(r: Int) : Void {
        currentRow = r;
        payloadCol = 1;
        payloadTop = patch.width;
        view = patch.getCellView();
        var dcode : Datum = patch.getCell(0,r);
        var code : String = view.toString(dcode);
        if (code=="@@") {
            applyHeader();
        } else if (code=="->") {
            applyUpdate();
        } else if (code=="+++") {
            applyInsert();
        } else if (code=="---") {
            applyDelete();
        } else if (code=="+") {
            applyPad();
        } else if (code=="!") {
            applyMeta();
        }
    }

    private function getDatum(c: Int) : Datum {
        return patch.getCell(c,currentRow);
    }

    private function getString(c: Int) : String {
        return view.toString(getDatum(c));
    }


    private function applyMeta() : Void {
        for (i in payloadCol...payloadTop) {
            var name : String = getString(i);
            if (name == "") continue;
            schemaModifier.set(i,name);
        }
    }
    private function applyHeader() : Void {
        for (i in payloadCol...payloadTop) {
            var name : String = getString(i);
            var mod : String = schemaModifier.get(i);
            if (mod!="+++") headerPre.set(name,i);
            if (mod!="---") headerPost.set(name,i);
        }
    }

    private function applyUpdate() : Void {
       needSourceIndex();
       var at : Int = lookUp();
       if (at==-1) return;
       var mod : HighlightPatchUnit = new HighlightPatchUnit();
       mod.sourceRow = at;
       mod.patchRow = currentRow;
       mods.push(mod);
    }

    private function applyInsert() : Void {
        needSourceIndex();
        var mod : HighlightPatchUnit = new HighlightPatchUnit();
        mod.add = true;
        var prev : Int = -1;
        var cont : Bool = false;
        if (currentRow>0) {
            if (view.equals(patch.getCell(0,currentRow),patch.getCell(0,currentRow-1))) {
                prev = -2;
            } else {
                currentRow--;
                prev = lookUp();
                currentRow++;
            }
        }
        if (prev==-2) {
            mod.sourceRow = mods[mods.length-1].sourceRow;
        } else {
            mod.sourceRow = (prev<0)?prev:(prev+1);
        }
        mod.patchRow = currentRow;
        mods.push(mod);
    }

    private function lookUp() : Int {
        for (idx in indexes) {
            var match : CrossMatch = idx.queryByContent(this);
            if (match.spot_a != 1) continue;
            return match.item_a.lst[0];
        }
        return -1;
    }

    private function applyDelete() : Void {
        needSourceIndex();
        var at : Int = lookUp();
        if (at==-1) return;
        var mod : HighlightPatchUnit = new HighlightPatchUnit();
        mod.rem = true;
        mod.sourceRow = at;
        mod.patchRow = currentRow;
        mods.push(mod);
    }

    private function applyPad() : Void {
    }

    private function getPreString(txt: String) : String {
        if (getString(0)!="->") {
            return txt;
        }
        return txt.split("->")[0];
    }

    private function getPostDatum(txt: String) : Datum {
        var rep : String = txt.split("->")[1];
        if (rep==null) return null;
        return view.toDatum(rep);
    }

    public function getRowString(c: Int) : String {
        var at : Null<Int> = sourceInPatch.get(c);
        if (at == null) return "NOT_FOUND"; // should be avoided
        return getPreString(getString(at));
    }

    private function finish() : Void {
        var sorter = function(a,b) { if (a.sourceRow==-1 && b.sourceRow!=-1) return 1; if (a.sourceRow!=-1 && b.sourceRow==-1) return -1; if (a.sourceRow>b.sourceRow) return 1; if (a.sourceRow<b.sourceRow) return -1; return 0; }
        mods.sort(sorter);
        var offset : Int = 0;
        var last : Int = 0;
        var target : Int = 0;
        var fate : Array<Int> = new Array<Int>();
        for (mod in mods) {
            //trace("Working on " + mod);
            if (last!=-1) {
                for (i in last...mod.sourceRow) {
                    fate.push(i+offset);
                    target++;
                    last++;
                }
            }
            if (mod.rem) {
                fate.push(-1);
                offset--;
            } else if (mod.add) {
                mod.sourceRow2 = target;
                target++;
                offset++;
            } else {
                mod.sourceRow2 = target;
            }
            if (mod.sourceRow>=0) {
                last = mod.sourceRow;
                if (mod.rem) last++;
            } else {
                last = -1;
            }
        }
        if (last!=-1) {
            for (i in last...source.height) {
                fate.push(i+offset);
                target++;
                last++;
            }
        }
        //trace(fate);
        source.insertOrDeleteRows(fate,source.height+offset);
        for (mod in mods) {
            if (!mod.rem) {
                //trace("Revisiting " + mod);
                if (mod.add) {
                    for (c in headerPost) {
                        source.setCell(patchInSource2.get(c),
                                       mod.sourceRow2,
                                       patch.getCell(c,mod.patchRow));
                    }
                } else if (!mod.rem) {
                    // update
                    for (c in headerPre) {
                        var d : Datum = 
                            getPostDatum(view.toString(patch.getCell(c,mod.patchRow)));
                        if (d==null) continue;
                        source.setCell(patchInSource2.get(c),
                                       mod.sourceRow2,
                                       d);
                    }
                }
            }
        }
    }
}
