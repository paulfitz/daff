// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Apply a tabular diff as a patch.
 *
 */
@:expose
class HighlightPatch implements Row {

    private var source : Table; // table to patch (src)
    private var patch : Table;  // table containing patch

    private var view : View;    // cached view for patch
    private var sourceView : View; // cached view for source
    private var csv : Csv;      // cached cell parser

    private var header : Map<Int,String>;            // (col -> name) in patch
    private var headerPre : Map<String,Int>;         // (name -> col) in src
    private var headerPost : Map<String,Int>;        // (name -> col) in dest
    private var headerRename : Map<String,String>;   // (name -> name)
    private var headerMove : Map<String,Int>;       // (name -> should_move)

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
    private var destInPatchCol : Map<Int,Int>;   // (dest col -> patch col)
    private var patchInDestCol : Map<Int,Int>;   // (patch col -> dest col)
    private var patchInSourceRow : Map<Int,Int>; // (patch row -> src row)
    private var lastSourceRow : Int;
    private var actions : Array<String>;
    private var rowPermutation : Array<Int>;
    private var rowPermutationRev : Array<Int>;
    private var colPermutation : Array<Int>;
    private var colPermutationRev : Array<Int>;
    private var haveDroppedColumns : Bool;
    private var headerRow : Int;
    private var preambleRow : Int;
    private var flags : CompareFlags;

    private var meta_change : Bool;
    private var process_meta : Bool;
    private var prev_meta : Map<String,Array<PropertyChange>>;
    private var next_meta : Map<String,Array<PropertyChange>>;

    private var finished_columns : Bool;
    private var meta : Meta;

    /**
     *
     * Constructor.
     *
     * @param source the table to patch
     * @param patch the tabular diff to use as a patch
     *
     */
    public function new(source: Table, patch: Table, ?flags : CompareFlags) {
        this.source = source;
        this.patch = patch;
        this.flags = flags;
        if (flags==null) this.flags = new CompareFlags();
        view = patch.getCellView();
        sourceView = source.getCellView();
        meta = source.getMeta();
    }

    private function reset() : Void {
        header = new Map<Int,String>();
        headerPre = new Map<String,Int>();
        headerPost = new Map<String,Int>();
        headerRename = new Map<String,String>();
        headerMove = null;
        modifier = new Map<Int,String>();
        mods = new Array<HighlightPatchUnit>();
        cmods = new Array<HighlightPatchUnit>();
        csv = new Csv();
        rcOffset = 0;
        currentRow = -1;
        rowInfo = new CellInfo();
        cellInfo = new CellInfo();

        sourceInPatchCol = patchInSourceCol = patchInDestCol = null;
        patchInSourceRow = new Map<Int,Int>();
        indexes = null;
        lastSourceRow = -1;
        actions = new Array<String>();
        rowPermutation = null;
        rowPermutationRev = null;
        colPermutation = null;
        colPermutationRev = null;
        haveDroppedColumns = false;
        headerRow = 0;
        preambleRow = 0;

        meta_change = false;
        process_meta = false;
        prev_meta = null;
        next_meta = null;

        finished_columns = false;
    }

    private function processMeta() {
        process_meta = true;
    }

    /**
     *
     * Apply the patch.
     *
     * @return true on success
     *
     */
    public function apply() : Bool {
        reset();
        if (patch.width<2) return true;
        if (patch.height<1) return true;
        payloadCol = 1+rcOffset;
        payloadTop = patch.width;
        var corner : String = patch.getCellView().toString(patch.getCell(0,0));
        rcOffset = (corner=="@:@") ? 1 : 0;
        for (r in 0...patch.height) {
            var str : String = view.toString(patch.getCell(rcOffset,r));
            actions.push((str!=null)?str:"");
        }
        preambleRow = headerRow = rcOffset;
        for (r in 0...patch.height) {
            applyRow(r);
        }
        finishColumns();
        finishRows();
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

    private function needDestColumns() : Void {
        if (patchInDestCol!=null) return;

        patchInDestCol = new Map<Int,Int>();
        destInPatchCol = new Map<Int,Int>();

        // make sure we know where dest columns are
        for (cmod in cmods) {
            if (cmod.patchRow!=-1) {
                patchInDestCol.set(cmod.patchRow,cmod.destRow);
                destInPatchCol.set(cmod.destRow,cmod.patchRow);
            }
        }
    }

    private function needSourceIndex() : Void {
        if (indexes!=null) return;
        var state : TableComparisonState = new TableComparisonState();
        state.a = source;
        state.b = source;
        var comp : CompareTable = new CompareTable(state);
        comp.storeIndexes();
        comp.run();
        comp.align();
        indexes = comp.getIndexes();
        needSourceColumns();
    }


    private function setMetaProp(target: Map<String,Array<PropertyChange>>,
                                 column_name: String, prop_name: String,
                                 value:Dynamic) {
        if (column_name==null) return;
        if (prop_name==null) return;
        if (!target.exists(column_name)) {
            target.set(column_name,new Array<PropertyChange>());
        }
        var change = new PropertyChange();
        change.prevName = prop_name;
        change.name = prop_name;
        if (value=="") value = null;  // normalize blank as null for meta information
        change.val = value;
        target.get(column_name).push(change);
    }

    private function applyMetaRow(code: String) : Void {
        needSourceColumns();
        //needDestColumns();
        var codes = code.split("@");
        var prop_name = "";
        if (codes.length>1) {
            prop_name = codes[codes.length-2];
        }
        if (codes.length>0) {
            code = codes[codes.length-1];
        }
        if (prev_meta==null) prev_meta = new Map<String,Array<PropertyChange>>();
        if (next_meta==null) next_meta = new Map<String,Array<PropertyChange>>();
        for (i in payloadCol...payloadTop) {
            var txt : String = getDatum(i);
            var idx_patch = i;
            var idx_src = patchInSourceCol.exists(idx_patch) ? patchInSourceCol.get(idx_patch) : -1;
            var prev_name : String = null;
            var name : String = null;
            if (idx_src!=-1) prev_name = source.getCell(idx_src,0);
            if (header.exists(idx_patch)) name = header.get(idx_patch);
            DiffRender.examineCell(0,0,view,txt,"",code,"",cellInfo);
            if (cellInfo.updated) {
                setMetaProp(prev_meta,prev_name,prop_name,cellInfo.lvalue);
                setMetaProp(next_meta,name,prop_name,cellInfo.rvalue);
            } else {
                setMetaProp(prev_meta,prev_name,prop_name,cellInfo.value);
                setMetaProp(next_meta,name,prop_name,cellInfo.value);
            }
        }
    }

    private function applyRow(r: Int) : Void {
        currentRow = r;
        var code : String = actions[r];
        var done = false;
        if (r==0 && rcOffset>0) {
            // skip rc row if present
            done = true;
        } else if (code=="@@") {
            preambleRow = headerRow = r;
            applyHeader();
            applyAction("@@");
            done = true;
        } else if (code=="!") {
            preambleRow = headerRow = r;
            applyMeta();
            done = true;
        } else if (code.indexOf("@")==0) {
            flags.addWarning("cannot usefully apply diffs with metadata yet: '" + code + "'");
            preambleRow = r;
            applyMetaRow(code);
            if (process_meta) {
                var codes = code.split("@");
                if (codes.length>0) {
                    code = codes[codes.length-1];
                }
            } else {
                meta_change = true;
                done = true;
            }
            meta_change = true;
            done = true;
        }
        if (process_meta) return; // don't do anything beyond this point
        if (!done) {
            finishColumns();
            if (code=="+++") {
                applyAction(code);
            } else if (code=="---") {
                applyAction(code);
            } else if (code=="+"||code==":") {
                applyAction(code);
            } else if (code.indexOf("->")>=0) {
                applyAction("->");
            } else {
                lastSourceRow = -1;
            }
        }
    }

    private function getDatum(c: Int) : Dynamic {
        return patch.getCell(c,currentRow);
    }

    private function getString(c: Int) : String {
        return view.toString(getDatum(c));
    }

    private function getStringNull(c: Int) : String {
        var d = getDatum(c);
        if (d==null) return null;
        return view.toString(d);
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
            if (name=="...") {
                modifier.set(i,"...");
                haveDroppedColumns = true;
                continue;
            }
            var mod : String = modifier.get(i);
            var move : Bool = false;
            if (mod!=null) {
                if (mod.charCodeAt(0)==":".code) {
                    move = true;
                    mod = mod.substr(1,mod.length);
                }
            }
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
            if (move) {
                if (headerMove==null) headerMove = new Map<String,Int>();
                headerMove.set(name,1);
            }
        }
        if (!useMetaForRowChanges()) {
            if (source.height==0) {
                applyAction("+++");
            }
        }
    }

    private function lookUp(del : Int = 0) : Int {
        if (patchInSourceRow.exists(currentRow+del)) {
            return patchInSourceRow.get(currentRow+del);
        }
        var result : Int = -1;
        currentRow += del;
        if (currentRow>=0 && currentRow<patch.height) {
            for (idx in indexes) {
                var match : CrossMatch = idx.queryByContent(this);
                if (match.spot_a == 0) continue;
                if (match.spot_a == 1) {
                    result = match.item_a.value();
                    break;
                }
                if (currentRow>0) {
                    var prev : Null<Int> = patchInSourceRow.get(currentRow-1);
                    if (prev!=null) {
                        var lst : Array<Int> = match.item_a.asList();
                        for (row in lst) {
                            if (row == prev+1) {
                                result = row;
                                break;
                            }
                        }
                    }
                }
            }
        }
        patchInSourceRow[currentRow] = result;
        currentRow -= del;
        return result;
    }

    private function applyActionExternal(code : String) : Void {
        if (code=="@@") return;

        var rc = new RowChange();
        rc.action = code;

        checkAct();
        if (code!="+++") rc.cond = new Map<String,Dynamic>();
        if (code!="---") rc.val = new Map<String,Dynamic>();
        var have_column = false;
        for (i in payloadCol...payloadTop) {
            var prev_name = header[i];
            var name = prev_name;
            if (headerRename.exists(prev_name)) {
                name = headerRename.get(prev_name);
            }
            var cact : String = modifier.get(i);
            if (cact=="...") continue;
            if (name==null || name=="") continue;
            var txt : String = csv.parseCell(getStringNull(i));
            var updated = false;
            if (rowInfo.updated) {
                getPreString(txt);
                updated = cellInfo.updated;
            }
            if (cact=="+++" && code!="---") {
                if (txt!=null && txt!="") {
                    if (rc.val==null) rc.val = new Map<String,Dynamic>();
                    rc.val.set(name,txt);
                    have_column = true;
                }
            }
            if (updated) {
                rc.cond.set(name,csv.parseCell(cellInfo.lvalue));
                rc.val.set(name,csv.parseCell(cellInfo.rvalue));
            } else if (code=="+++") {
                if (cact!="---") rc.val.set(name,txt);
            } else {
                if (cact!="+++" && cact!="---") {
                    rc.cond.set(name,txt);
                }
            }
        }
        if (rc.action == "+") {
            if (!have_column) return;
            rc.action = "->";
        }
        meta.changeRow(rc);
    }


    private function applyAction(code : String) : Void {
        if (useMetaForRowChanges()) {
            applyActionExternal(code);
            return;
        }
        var mod : HighlightPatchUnit = new HighlightPatchUnit();
        mod.code = code;
        mod.add = (code == "+++");
        mod.rem = (code == "---");
        mod.update = (code == "->");
        needSourceIndex();
        if (lastSourceRow==-1) {
            lastSourceRow = lookUp(-1);
        }
        mod.sourcePrevRow = lastSourceRow;
        var nextAct : String = actions[currentRow+1];
        if (nextAct!="+++" && nextAct!="...") {
            mod.sourceNextRow = lookUp(1);
        } 
        if (mod.add) {
            if (actions[currentRow-1]!="+++") {
                if (actions[currentRow-1]=="@@") {
                    mod.sourcePrevRow = 0;
                    lastSourceRow = 0;
                } else {
                    mod.sourcePrevRow = lookUp(-1);
                }
            }
            mod.sourceRow = mod.sourcePrevRow;
            if (mod.sourceRow!=-1) mod.sourceRowOffset = 1;
        } else {
            mod.sourceRow = lastSourceRow = lookUp();
        }
        if (actions[currentRow+1]=="") {
            lastSourceRow = mod.sourceNextRow;
        }
        mod.patchRow = currentRow;
        if (code == "@@") {
            mod.sourceRow = 0;
        }
        mods.push(mod);
    }

    private function checkAct() : Void {
        var act : String = getString(rcOffset);

        if (rowInfo.value != act) {
            DiffRender.examineCell(0,0,view,act,"",act,"",rowInfo);
        }
    }

    private function getPreString(txt: String) : String {
        checkAct();

        if (!rowInfo.updated) return txt;
        DiffRender.examineCell(0,0,view,txt,"",rowInfo.value,"",cellInfo);
        if (!cellInfo.updated) return txt;
        return cellInfo.lvalue;
    }

    /**
     *
     * Get the content in a given column of the patch on the active row.
     * This is present for generating keys internally, you don't need it.
     * 
     * @param c the column to look in
     * @return the content of column `c` on the active row
     *
     */
    public function getRowString(c: Int) : String {
        var at : Null<Int> = sourceInPatchCol.get(c);
        if (at == null) return "NOT_FOUND"; // should be avoided
        return getPreString(getString(at));
    }

    public function isPreamble() : Bool {
        return (currentRow<=preambleRow);
    }

    private function sortMods(a: HighlightPatchUnit,b: HighlightPatchUnit) {
        // Sort by sourceRow
        // Then by patchRow
        if (b.code=="@@" && a.code!="@@") return 1;
        if (a.code=="@@" && b.code!="@@") return -1;
        if (a.sourceRow==-1 && (!a.add) && b.sourceRow!=-1) return 1; 
        if (a.sourceRow!=-1 && (!b.add) && b.sourceRow==-1) return -1; 
        if (a.sourceRow+a.sourceRowOffset>b.sourceRow+b.sourceRowOffset) return 1; 
        if (a.sourceRow+a.sourceRowOffset<b.sourceRow+b.sourceRowOffset) return -1; 
        if (a.patchRow>b.patchRow) return 1; 
        if (a.patchRow<b.patchRow) return -1; return 0;
    }

    // This works out rows/cols to add or delete or move
    private function processMods(rmods : Array<HighlightPatchUnit>,
                                 fate: Array<Int>,
                                 len: Int) : Int {
        rmods.sort(sortMods);
        var offset : Int = 0;
        var last : Int = -1;
        var target : Int = 0;
        if (rmods.length>0) {
            if (rmods[0].sourcePrevRow == -1) {
                last = 0;
            }
        }
        for (mod in rmods) {
            if (last!=-1) {
                for (i in last...(mod.sourceRow+mod.sourceRowOffset)) {
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
                last = mod.sourceRow+mod.sourceRowOffset;
                if (mod.rem) last++;
            } else {
                if (mod.add && mod.sourceNextRow!=-1) {
                    last = mod.sourceNextRow+mod.sourceRowOffset;
                } else {
                    if (mod.rem||mod.add) {
                        last = -1;
                    }
                }
            }
        }
        if (last!=-1) {
            for (i in last...len) {
                fate.push(i+offset);
                target++;
                last++;
            }
        }
        return len+offset;
    }

    private function useMetaForColumnChanges() : Bool {
        if (meta==null) return false;
        return meta.useForColumnChanges();
    }

    private function useMetaForRowChanges() : Bool {
        if (meta==null) return false;
        return meta.useForRowChanges();
    }

    private function computeOrdering(mods : Array<HighlightPatchUnit>,
                                     permutation : Array<Int>,
                                     permutationRev : Array<Int>,
                                     dim : Int) : Void {
        // choose a permutation of source rows s.t. mods
        // can be rewritten to have pretty mod.sourceRow/mod.sourcePrevRow
        // relationships
        var to_unit : Map<Int,Int> = new Map<Int,Int>(); 
        var from_unit : Map<Int,Int> = new Map<Int,Int>();
        var meta_from_unit : Map<Int,Int> = new Map<Int,Int>();
        var ct : Int = 0;
        for (mod in mods) {
            if (mod.add||mod.rem) continue;
            if (mod.sourceRow<0) continue;
            if (mod.sourcePrevRow>=0) {
                to_unit[mod.sourcePrevRow] = mod.sourceRow;
                from_unit[mod.sourceRow] = mod.sourcePrevRow;
                if (mod.sourcePrevRow+1!=mod.sourceRow) {
                    ct++;
                }
            }
            if (mod.sourceNextRow>=0) {

                to_unit[mod.sourceRow] = mod.sourceNextRow;
                from_unit[mod.sourceNextRow] = mod.sourceRow;
                if (mod.sourceRow+1!=mod.sourceNextRow) {
                    ct++;
                }
            }
        }
        
        if (ct>0) {
            var cursor : Null<Int> = null;
            var logical : Null<Int> = null;
            var starts : Array<Int> = [];
            for (i in 0...dim) {
                var u : Null<Int> = from_unit[i];
                if (u!=null) {
                    meta_from_unit[u] = i;
                } else {
                    starts.push(i);
                }
            }
            var used : Map<Int,Int> = new Map<Int,Int>();
            var len : Int = 0;
            for (i in 0...dim) {
                if (logical!=null && meta_from_unit.exists(logical)) {
                    cursor = meta_from_unit[logical];
                } else {
                    cursor = null;
                }
                if (cursor == null) {
                    var v : Int = starts.shift();
                    cursor = v;
                    logical = v;
                }
                if (cursor == null) {
                    cursor = 0;
                }
                while (used.exists(cursor)) {
                    cursor = (cursor + 1) % dim;
                }
                logical = cursor;
                permutationRev.push(cursor);
                used[cursor] = 1;
            }
            for (i in 0...permutationRev.length) {
                permutation[i] = -1;
            }
            for (i in 0...permutation.length) {
                permutation[permutationRev[i]] = i;
            }
        }
    }

    private function permuteRows() : Void {
        rowPermutation = new Array<Int>();
        rowPermutationRev = new Array<Int>();
        computeOrdering(mods,rowPermutation,rowPermutationRev,source.height);
    }

    private function fillInNewColumns() : Void {
        for (cmod in cmods) {
            if (!cmod.rem) {
                if (cmod.add) {
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
    }

    private function finishRows() : Void {
        if (useMetaForRowChanges()) {
            // row changes have already happened in this case
            return;
        }

        if (source.width==0) {
            // no columns left
            if (source.height!=0) {
                // behavior of native tables not defined when a dimension is 0
                // so we normalize
                source.resize(0,0);
            }
            return;
        }

        var fate : Array<Int> = new Array<Int>();
        permuteRows();
        if (rowPermutation.length>0) {
            for (mod in mods) {
                if (mod.sourceRow>=0) {
                    mod.sourceRow = rowPermutation[mod.sourceRow];
                }
            }
        }

        if (rowPermutation.length>0) {
            source.insertOrDeleteRows(rowPermutation,rowPermutation.length);
        }

        var len : Int = processMods(mods,fate,source.height);
        source.insertOrDeleteRows(fate,len);

        needDestColumns();
        for (mod in mods) {
            if (!mod.rem) {
                if (mod.add) {
                    for (c in headerPost) {
                        var offset : Null<Int> = patchInDestCol.get(c);
                        if (offset!=null && offset>=0) {
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
                        DiffRender.examineCell(0,0,view,txt,"",rowInfo.value,"",cellInfo);
                        if (!cellInfo.updated) continue;
                        if (cellInfo.conflicted) continue; // skip conflicted
                        var d : Dynamic = view.toDatum(csv.parseCell(cellInfo.rvalue));
                        var offset = patchInDestCol.get(c);
                        if (offset!=null && offset>=0) {
                            source.setCell(patchInDestCol.get(c),
                                           mod.destRow,
                                           d);
                        }
                    }
                }
            }
        }

        fillInNewColumns();
        for (i in 0...source.width) {
            var name : String = view.toString(source.getCell(i,0));
            var next_name : String = headerRename.get(name);
            if (next_name==null) continue;
            source.setCell(i,0,view.toDatum(next_name));
        }
    }

    private function permuteColumns() : Void {
        if (headerMove == null) return;
        colPermutation = new Array<Int>();
        colPermutationRev = new Array<Int>();
        computeOrdering(cmods,colPermutation,colPermutationRev,source.width);
        if (colPermutation.length==0) return;
    }

    private function finishColumns() : Void {
        if (finished_columns) return;
        finished_columns = true;
        needSourceColumns();
        for (i in payloadCol...payloadTop) {
            var act : String = modifier.get(i);
            var hdr : String = header.get(i);
            if (act==null) act = "";
            if (act=="---") {
                var at : Int = -1;
                if (patchInSourceCol.exists(i)) at = patchInSourceCol.get(i);
                var mod : HighlightPatchUnit = new HighlightPatchUnit();
                mod.code = act;
                mod.rem = true;
                mod.sourceRow = at;
                mod.patchRow = i;
                cmods.push(mod);
            } else if (act=="+++") {
                var mod : HighlightPatchUnit = new HighlightPatchUnit();
                mod.code = act;
                mod.add = true;
                var prev : Int = -1;
                var cont : Bool = false;
                mod.sourceRow = -1;
                if (cmods.length>0) {
                    mod.sourceRow = cmods[cmods.length-1].sourceRow;
                }
                if (mod.sourceRow!=-1) {
                    mod.sourceRowOffset = 1;
                }
                mod.patchRow = i;
                cmods.push(mod);
            } else if (act!="...") {
                var at : Int = -1;
                if (patchInSourceCol.exists(i)) at = patchInSourceCol.get(i);
                var mod : HighlightPatchUnit = new HighlightPatchUnit();
                mod.code = act;
                mod.patchRow = i;
                mod.sourceRow = at;
                cmods.push(mod);
            }
        }
        var at : Int = -1;
        var rat : Int = -1;
        for (i in 0...cmods.length-1) {
            var icode : String = cmods[i].code;
            if (icode != "+++" && icode != "---") {
                at = cmods[i].sourceRow;
            }
            cmods[i+1].sourcePrevRow = at;
            var j: Int = cmods.length-1-i;
            var jcode : String = cmods[j].code;
            if (jcode != "+++" && jcode != "---") {
                rat = cmods[j].sourceRow;
            }
            cmods[j-1].sourceNextRow = rat;            
        }
        var fate : Array<Int> = new Array<Int>();
        permuteColumns();
        if (headerMove!=null) {
            if (colPermutation.length>0) {
                for (mod in cmods) {
                    if (mod.sourceRow>=0) {
                        mod.sourceRow = colPermutation[mod.sourceRow];
                    }
                }
                if (!useMetaForColumnChanges()) {
                    source.insertOrDeleteColumns(colPermutation,colPermutation.length);
                }
            }
        }

        var len : Int = processMods(cmods,fate,source.width);

        if (!useMetaForColumnChanges()) {
            source.insertOrDeleteColumns(fate,len);
            return;
        }

        var changed = false;
        for (mod in cmods) {
            if (mod.code!="") {
                changed = true;
                break;
            }
        }
        if (!changed) return;

        var columns = new Array<ColumnChange>();
        var target = new Map<Int,Int>();
        var inc = function(x : Int) {
            return (x<0)?x:(x+1);
        }
        for (i in 0...fate.length) {
            target.set(i,inc(fate[i]));
        }
        needSourceColumns();
        needDestColumns();
        for (idx_patch in 1...patch.width) {
            var change = new ColumnChange();
            var idx_src = patchInSourceCol.exists(idx_patch) ? patchInSourceCol.get(idx_patch) : -1;
            var prev_name : String = null;
            var name : String = null;
            if (idx_src!=-1) prev_name = source.getCell(idx_src,0);
            if (modifier.get(idx_patch)!="---") {
                if (header.exists(idx_patch)) name = header.get(idx_patch);
            }
            change.prevName = prev_name;
            change.name = name;
            if (next_meta!=null) {
                if (next_meta.exists(name)) {
                    change.props = next_meta.get(name);
                }
            }
            columns.push(change);
        }
        meta.alterColumns(columns);
    }
}
