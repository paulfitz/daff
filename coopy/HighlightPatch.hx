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
    private var header : Map<Int,String>;
    private var headerPre : Map<String,Int>;
    private var headerPost : Map<String,Int>;
    private var modifier : Map<Int,String>;
    private var indexes : Array<IndexPair>;
    private var sourceInPatch : Map<Int,Int>;
    private var patchInSource : Map<Int,Int>;
    private var mods : Array<HighlightPatchUnit>;
    private var cmods : Array<HighlightPatchUnit>;
    private var haveSourceColumns : Bool;

    public function new(source: Table, patch: Table) {
        this.source = source;
        this.patch = patch;
        header = new Map<Int,String>();
        headerPre = new Map<String,Int>();
        headerPost = new Map<String,Int>();
        modifier = new Map<Int,String>();
        sourceInPatch = new Map<Int,Int>();
        patchInSource = new Map<Int,Int>();
        mods = new Array<HighlightPatchUnit>();
        cmods = new Array<HighlightPatchUnit>();
        haveSourceColumns = false;
    }

    public function apply() : Bool {
        if (patch.width<2) return true;
        for (r in 0...patch.height) {
            applyRow(r);
        }
        finishRows();
        finishColumns();
        return true;
    }

    private function needSourceColumns() : Void {
        if (haveSourceColumns) return;
        // make sure we know where source columns are
        var av : View = source.getCellView();
        for (i in 0...source.width) {
            var name : String = av.toString(source.getCell(i,0));
            var at : Null<Int> = headerPre.get(name);
            if (at == null) continue;
            sourceInPatch.set(i,at);
            patchInSource.set(at,i);  // needs tweak for add/rems
        }
        haveSourceColumns = true;
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
        needSourceColumns();
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
            modifier.set(i,name);
        }
    }
    private function applyHeader() : Void {
        for (i in payloadCol...payloadTop) {
            var name : String = getString(i);
            var mod : String = modifier.get(i);
            header.set(i,name);
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

    private function processMods(rmods : Array<HighlightPatchUnit>,
                                 fate: Array<Int>,
                                 len: Int) : Int {
        var sorter = function(a,b) { if (a.sourceRow==-1 && b.sourceRow!=-1) return 1; if (a.sourceRow!=-1 && b.sourceRow==-1) return -1; if (a.sourceRow>b.sourceRow) return 1; if (a.sourceRow<b.sourceRow) return -1; return 0; }
        mods.sort(sorter);
        var offset : Int = 0;
        var last : Int = 0;
        var target : Int = 0;
        for (mod in rmods) {
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
            for (i in last...len) {
                fate.push(i+offset);
                target++;
                last++;
            }
        }
        //trace(fate);
        //trace(len+offset);
        return len+offset;
    }

    private function finishRows() : Void {
        var fate : Array<Int> = new Array<Int>();
        var len : Int = processMods(mods,fate,source.height);
        source.insertOrDeleteRows(fate,len);
        for (mod in mods) {
            if (!mod.rem) {
                //trace("Revisiting " + mod);
                if (mod.add) {
                    for (c in headerPost) {
                        source.setCell(patchInSource.get(c),
                                       mod.sourceRow2,
                                       patch.getCell(c,mod.patchRow));
                    }
                } else if (!mod.rem) {
                    // update
                    for (c in headerPre) {
                        var d : Datum = 
                            getPostDatum(view.toString(patch.getCell(c,mod.patchRow)));
                        if (d==null) continue;
                        source.setCell(patchInSource.get(c),
                                       mod.sourceRow2,
                                       d);
                    }
                }
            }
        }
    }

    private function finishColumns() : Void {
        needSourceColumns();
        for (i in payloadCol...payloadTop) {
            var mod : String = modifier.get(i);
            var hdr : String = header.get(i);
            if (mod=="---") {
                //trace("Should remove column " + hdr);
                var at : Int = patchInSource.get(i);
                var mod : HighlightPatchUnit = new HighlightPatchUnit();
                mod.rem = true;
                mod.sourceRow = at;
                mod.patchRow = i;
                cmods.push(mod);
            } else if (mod=="+++") {
                //trace("Should add column " + hdr);
                var mod : HighlightPatchUnit = new HighlightPatchUnit();
                mod.add = true;
                var prev : Int = -1;
                var cont : Bool = false;
                if (i>payloadCol) {
                    if (modifier.get(i)==modifier.get(i-1)) {
                        prev = -2;
                    } else {
                        var p : Null<Int> = patchInSource.get(i-1);
                        prev = (p==null)?-1:p;
                    }
                }
                if (prev==-2) {
                    mod.sourceRow = cmods[mods.length-1].sourceRow;
                } else {
                    mod.sourceRow = (prev<0)?prev:(prev+1);
                }
                mod.patchRow = i;
                cmods.push(mod);
            }
        }
        var fate : Array<Int> = new Array<Int>();
        var len : Int = processMods(cmods,fate,source.width);
        source.insertOrDeleteColumns(fate,len);
        for (cmod in cmods) {
            if (!cmod.rem) {
                if (cmod.add) {
                    //trace("Should fill in " + cmod.sourceRow2 + " from " +
                    //cmod.patchRow);
                    // we're not ready yet, but at least pop in
                    // column name
                    var hdr : String = header.get(cmod.patchRow);
                    source.setCell(cmod.sourceRow2,
                                   0,
                                   view.toDatum(hdr));
                }
            }
        }
    }
}
