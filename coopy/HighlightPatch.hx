// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class HighlightPatch implements Row {

    private var source : Table; // table to patch (src)
    private var patch : Table;  // table containing patch

    private var view : View;    // cached view for patch
    private var csv : Csv;      // cached cell parser

    private var header : Map<Int,String>;            // (col -> name) in patch
    private var headerPre : Map<String,Int>;         // (name -> col) in src
    private var headerPost : Map<String,Int>;        // (name -> col) in dest
    private var headerRename : Map<String,String>;   // (name -> name)

    private var modifier : Map<Int,String>;          // (col -> modifier) patch

    private var currentRow : Int; // current row of patch being evaluated

    private var payloadCol : Int; // first column of data in patch
    private var payloadTop : Int; // number of columns in patch

    private var mods : Array<HighlightPatchUnit>;  // row modification list
    private var cmods : Array<HighlightPatchUnit>; // column modification list

    private var rowInfo : CellInfo;  // information gleaned from action column
    private var cellInfo : CellInfo; // information gleaned from current cell

    private var rcOffset : Int; // offset for row/column information

    private var indexes : Array<IndexPair>; // cached indexes for querying src
    private var sourceInPatchCol : Map<Int,Int>; // (src col -> patch col)
    private var patchInSourceCol : Map<Int,Int>; // (patch col -> src col)
    private var patchInSourceRow : Map<Int,Int>; // (patch row -> src row)
    private var lastSourceRow : Int;
    private var lastAction : String;

    public function new(source: Table, patch: Table) {
        this.source = source;
        this.patch = patch;
        view = patch.getCellView();
    }
     
    public function reset() : Void {
        header = new Map<Int,String>();
        headerPre = new Map<String,Int>();
        headerPost = new Map<String,Int>();
        headerRename = new Map<String,String>();
        modifier = new Map<Int,String>();
        mods = new Array<HighlightPatchUnit>();
        cmods = new Array<HighlightPatchUnit>();
        csv = new Csv();
        rcOffset = 0;
        currentRow = -1;
        rowInfo = new CellInfo();
        cellInfo = new CellInfo();

        sourceInPatchCol = patchInSourceCol = null;
        patchInSourceRow = new Map<Int,Int>();
        indexes = null;
        lastSourceRow = -1;
        lastAction = "";
    }

    public function apply() : Bool {
        reset();
        if (patch.width<2) return true;
        if (patch.height<1) return true;
        payloadCol = 1+rcOffset;
        payloadTop = patch.width;
        var corner : String = patch.getCellView().toString(patch.getCell(0,0));
        rcOffset = (corner=="@:@") ? 1 : 0;
        for (r in 0...patch.height) {
            applyRow(r);
        }
        finishRows();
        finishColumns();
        return true;
    }

    private function needSourceColumns() : Void {
        if (sourceInPatchCol!=null) return;
        sourceInPatchCol = new Map<Int,Int>();
        patchInSourceCol = new Map<Int,Int>();

        // make sure we know where source columns are
        var av : View = source.getCellView();
        for (i in 0...source.width) {
            var name : String = av.toString(source.getCell(i,0));
            var at : Null<Int> = headerPre.get(name);
            if (at == null) continue;
            sourceInPatchCol.set(i,at);
            patchInSourceCol.set(at,i);  // needs tweak for add/rems
        }
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
        var code : String = view.toString(patch.getCell(rcOffset,r));
        if (r==0 && rcOffset>0) {
            // skip rc row if present
        } else if (code=="@@") {
            applyHeader();
            applyAction("@@");
        } else if (code=="!") {
            applyMeta();
        } else if (code=="+++") {
            applyAction(code);
        } else if (code=="---") {
            applyAction(code);
        } else if (code=="+"||code==":") {
            applyAction(code);
        } else if (code.indexOf("->")>=0) {
            applyAction("->");
        }
        lastAction = code;
    }

    private function getDatum(c: Int) : Dynamic {
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
            if (mod!=null) {
                if (mod.charCodeAt(0)=="(".code) {
                    var prev_name = mod.substr(1,mod.length-2);
                    headerPre.set(prev_name,i);
                    headerPost.set(name,i);
                    headerRename.set(prev_name,name);
                    continue;
                }
            }
            if (mod!="+++") headerPre.set(name,i);
            if (mod!="---") headerPost.set(name,i);
        }
        if (source.height==0) {
            applyAction("+++");
        }
    }

    private function lookUp(del : Int = 0) : Int {
        var at : Null<Int> = patchInSourceRow.get(currentRow+del);
        if (at!=null) return at;
        var result : Int = -1;
        currentRow += del;
        if (currentRow>=0) {
            for (idx in indexes) {
                var match : CrossMatch = idx.queryByContent(this);
                if (match.spot_a != 1) continue;
                result = match.item_a.lst[0];
                break;
            }
        }
        patchInSourceRow[currentRow] = result;
        currentRow -= del;
        return result;
    }

    private function applyAction(code : String) : Void {
        var mod : HighlightPatchUnit = new HighlightPatchUnit();
        mod.add = (code == "+++");
        mod.rem = (code == "---");
        mod.update = (code == "->");
        needSourceIndex();
        mod.sourcePrevRow = lastSourceRow;
        if (mod.add) {
            if (lastAction!="+++") {
                mod.sourcePrevRow = lookUp(-1);
            }
            mod.sourceRow = mod.sourcePrevRow;
            if (mod.sourceRow!=-1) mod.sourceRow++;
        } else {
            mod.sourceRow = lastSourceRow = lookUp();
        }
        mod.patchRow = currentRow;
        if (code!="@@") mods.push(mod);
    }

    private function checkAct() : Void {
        var act : String = getString(rcOffset);

        if (rowInfo.value != act) {
            DiffRender.examineCell(0,0,act,"",act,"",rowInfo);
        }
    }

    private function getPreString(txt: String) : String {
        checkAct();

        if (!rowInfo.updated) return txt;
        DiffRender.examineCell(0,0,txt,"",rowInfo.value,"",cellInfo);
        if (!cellInfo.updated) return txt;
        return cellInfo.lvalue;
    }

    public function getRowString(c: Int) : String {
        var at : Null<Int> = sourceInPatchCol.get(c);
        if (at == null) return "NOT_FOUND"; // should be avoided
        return getPreString(getString(at));
    }

    private function sortMods(a: HighlightPatchUnit,b: HighlightPatchUnit) {
        // Sort by sourceRow
        // Then by patchRow
        if (a.sourceRow==-1 && b.sourceRow!=-1) return 1; 
        if (a.sourceRow!=-1 && b.sourceRow==-1) return -1; 
        if (a.sourceRow>b.sourceRow) return 1; 
        if (a.sourceRow<b.sourceRow) return -1; 
        if (a.patchRow>b.patchRow) return 1; 
        if (a.patchRow<b.patchRow) return -1; return 0;
    }

    // This works out rows/cols to add or delete or move
    private function processMods(rmods : Array<HighlightPatchUnit>,
                                 fate: Array<Int>,
                                 len: Int) : Int {
        mods.sort(sortMods);
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
                mod.destRow = target;
                target++;
                offset++;
            } else {
                mod.destRow = target;
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
            //trace("Revisiting " + mod);
            if (!mod.rem) {
                if (mod.add) {
                    for (c in headerPost) {
                        var offset : Int = patchInSourceCol.get(c);
                        if (offset>=0) {
                            source.setCell(offset,
                                           mod.destRow,
                                           patch.getCell(c,mod.patchRow));
                        }
                    }
                } else if (mod.update) {
                    // update
                    currentRow = mod.patchRow;
                    checkAct();
                    if (!rowInfo.updated) continue;
                    for (c in headerPre) {
                        
                        var txt : String = view.toString(patch.getCell(c,mod.patchRow));
                        DiffRender.examineCell(0,0,txt,"",rowInfo.value,"",cellInfo);
                        if (!cellInfo.updated) continue;
                        if (cellInfo.conflicted) continue; // skip conflicted
                        var d : Dynamic = view.toDatum(csv.parseSingleCell(cellInfo.rvalue));
                        source.setCell(patchInSourceCol.get(c),
                                       mod.destRow,
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
                var at : Int = patchInSourceCol.get(i);
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
                        var p : Null<Int> = patchInSourceCol.get(i-1);
                        prev = (p==null)?-1:p;
                    }
                }
                if (prev==-2) {
                    mod.sourceRow = cmods[cmods.length-1].sourceRow;
                } else {
                    mod.sourceRow = prev+1; //(prev<0)?prev:(prev+1);
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
                    //trace("Should fill in " + cmod.destRow + " from " +
                    //    cmod.patchRow);
                    // we're not ready yet, but at least pop in
                    // column name
                    for (mod in mods) {
                        if (mod.patchRow!=-1 && mod.destRow!=-1) {
                            var d : Dynamic = patch.getCell(cmod.patchRow,
                                                            mod.patchRow);
                            source.setCell(cmod.destRow,
                                           mod.destRow,
                                           d);
                        }
                    }
                    var hdr : String = header.get(cmod.patchRow);
                    source.setCell(cmod.destRow,
                                   0,
                                   view.toDatum(hdr));
                }
            }
        }
        for (i in 0...source.width) {
            var name : String = view.toString(source.getCell(i,0));
            var next_name : String = headerRename.get(name);
            if (next_name==null) continue;
            source.setCell(i,0,view.toDatum(next_name));
        }
    }
}
