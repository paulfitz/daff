// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Merge changes made in one table into another, given knowledge
 * of a common ancestor.
 *
 */
@:expose
class Merger {
    private var parent : Table;
    private var local : Table;
    private var remote : Table;
    private var flags : CompareFlags;
    private var order : Ordering;
    private var units : Array<Unit>;
    private var column_order : Ordering;
    private var column_units : Array<Unit>;
    private var row_mix_local : Map<Int,Int>;
    private var row_mix_remote : Map<Int,Int>;
    private var column_mix_local : Map<Int,Int>;
    private var column_mix_remote : Map<Int,Int>;
    private var conflicts : Int;
    private var conflict_infos : Array<ConflictInfo>;

    /**
     *
     * Constructor.
     *
     * @param parent the common ancestor
     * @param local the reference table into which changes will be merged
     * @param remote the table we are pulling changes from
     *
     */
    public function new(parent: Table, local: Table, remote: Table,
                        flags: CompareFlags) {
        this.parent = parent;
        this.local = local;
        this.remote = remote;
        this.flags = flags;
    }

    private function shuffleDimension(dim_units: Array<Unit>, len: Int,
                                     fate: Array<Int>,
                                     cl: Map<Int,Int>,
                                     cr: Map<Int,Int>) : Int {
        var at = 0;
        for (cunit in dim_units) {
            if (cunit.p<0) {
                if (cunit.l<0) {
                    if (cunit.r>=0) {
                        // need to add this column/row
                        cr[cunit.r] = at;
                        at++;
                    }
                } else {
                    cl[cunit.l] = at;
                    at++;
                }
            } else {
                if (cunit.l>=0) {
                    if (cunit.r<0) {
                        // need to remove this column/row
                    } else {
                        cl[cunit.l] = at;
                        at++;
                    }
                }
            }
        }
        for (x in 0...len) {
            var idx = cl.get(x);
            if (idx==null) {
                fate.push(-1);
            } else {
                fate.push(idx);
            }
        }
        return at;
    }

    private function shuffleColumns() {
        column_mix_local = new Map<Int,Int>();
        column_mix_remote = new Map<Int,Int>();
        var fate = new Array<Int>();
        var wfate = shuffleDimension(column_units,local.width,fate,
                                     column_mix_local,column_mix_remote);
        local.insertOrDeleteColumns(fate,wfate);
    }

    private function shuffleRows() {
        row_mix_local = new Map<Int,Int>();
        row_mix_remote = new Map<Int,Int>();
        var fate = new Array<Int>();
        var hfate = shuffleDimension(units,local.height,fate,
                                     row_mix_local,row_mix_remote);
        local.insertOrDeleteRows(fate,hfate);
    }

    /**
     *
     * Go ahead and merge.
     *
     * @return the number of conflicts found during the merge
     *
     */
    public function apply() : Int {
        conflicts = 0;
        conflict_infos = new Array<ConflictInfo>();

        var ct : CompareTable = Coopy.compareTables3(parent,local,remote);
        var align : Alignment = ct.align();
        // now, modify "a" to incorporate parent->b changes
        // delete any rows/cols deleted in parent->b
        // insert any rows/cols inserted in parent->b
        // row/col movement -- ignore for now

        order = align.toOrder();
        units = order.getList();
        column_order = align.meta.toOrder();
        column_units = column_order.getList();

        var allow_insert : Bool = flags.allowInsert();
        var allow_delete : Bool = flags.allowDelete();
        var allow_update : Bool = flags.allowUpdate();

        // check for cell changes
        var view = parent.getCellView();
        for (row in units) {
            if (row.l>=0 && row.r>=0 && row.p>=0) {
                for (col in column_units) {
                    if (col.l>=0 && col.r>=0 && col.p>=0) {
                        var pcell = parent.getCell(col.p,row.p);
                        var rcell = remote.getCell(col.r,row.r);
                        if (!view.equals(pcell,rcell)) {
                            var lcell = local.getCell(col.l,row.l);
                            if (view.equals(pcell,lcell)) {
                                local.setCell(col.l,row.l,rcell);
                            } else if (!view.equals(rcell,lcell)) {
                                local.setCell(col.l,row.l,
                                              makeConflictedCell(view,pcell,lcell,rcell));
                                conflicts++;
                                addConflictInfo(row.l,col.l,view,pcell,lcell,rcell);
                            }
                        }
                    }
                }
            }
        }

        // rearrange columns and rows as appropriate
        shuffleColumns();
        shuffleRows();

        // paste in any new columns
        for (x in column_mix_remote.keys()) {
            var x2 = column_mix_remote.get(x);
            for (unit in units) {
                if (unit.l>=0 && unit.r>=0) {
                    local.setCell(x2,row_mix_local.get(unit.l),
                                  remote.getCell(x,unit.r));
                } else if (unit.p<0 && unit.r>=0) {
                    local.setCell(x2,row_mix_remote.get(unit.r),
                                  remote.getCell(x,unit.r));
                }
            }
        }

        // paste in any new rows
        for (y in row_mix_remote.keys()) {
            var y2 = row_mix_remote.get(y);
            for (unit in column_units) {
                if (unit.l>=0 && unit.r>=0) {
                    local.setCell(column_mix_local.get(unit.l),y2,
                                  remote.getCell(unit.r,y));
                }
            }
        }

        return conflicts;
    }

    public function getConflictInfos() : Array<ConflictInfo> {
        return conflict_infos;
    }

    private function addConflictInfo(row: Int,
                                     col: Int,
                                     view: View,
                                     pcell: Dynamic,
                                     lcell: Dynamic,
                                     rcell: Dynamic) : Void {
        conflict_infos.push(new ConflictInfo(row,
                                             col,
                                             view.toString(pcell),
                                             view.toString(lcell),
                                             view.toString(rcell)));
    }

    private static function makeConflictedCell(view: View,
                                               pcell: Dynamic,
                                               lcell: Dynamic,
                                               rcell: Dynamic) : Dynamic {
        return view.toDatum("((( " +
                            view.toString(pcell) +
                            " ))) " +
                            view.toString(lcell) + 
                            " /// " +
                            view.toString(rcell));
    }
}

