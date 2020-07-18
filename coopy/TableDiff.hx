// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Build a highlighter diff of two/three tables.
 *
 */
@:expose
class TableDiff {
    private var align : Alignment;
    private var flags : CompareFlags;
    private var builder : CellBuilder;

    private var row_map : Map<Int,Unit>;
    private var col_map : Map<Int,Unit>;
    private var has_parent : Bool;
    private var a : Table;
    private var b : Table;
    private var p : Table;
    private var rp_header : Int;
    private var ra_header : Int;
    private var rb_header : Int;
    private var is_index_p : Map<Int,Bool>;
    private var is_index_a : Map<Int,Bool>;
    private var is_index_b : Map<Int,Bool>;

    private var order : Ordering;
    private var row_units : Array<Unit>;
    private var column_units : Array<Unit>;

    private var show_rc_numbers : Bool;
    private var row_moves : Map<Int,Int>;
    private var col_moves : Map<Int,Int>;

    private var active_row : Array<Int>;
    private var active_column : Array<Int>;

    private var allow_insert : Bool;
    private var allow_delete : Bool;
    private var allow_update : Bool;
    private var allow_column : Bool;

    private var v : View;

    private var sep : String;
    private var conflict_sep : String;

    private var schema : Array<String>;
    private var have_schema : Bool;

    private var top_line_done : Bool;

    // Per-row state
    private var have_addition : Bool;
    private var act : String;
    private var publish : Bool;

    private var diff_found : Bool;
    private var schema_diff_found : Bool;
    private var preserve_columns : Bool;

    private var row_deletes : Int;
    private var row_inserts : Int;
    private var row_updates : Int;
    private var row_reorders : Int;

    private var col_deletes : Int;
    private var col_inserts : Int;
    private var col_updates : Int;
    private var col_renames : Int;
    private var col_reorders : Int;
    private var column_units_updated : Map<Int,Bool>;

    private var nested : Bool;
    private var nesting_present : Bool;

    /**
     *
     * Constructor.
     *
     * @param align a pre-computed alignment of the tables involved
     * @param flags options to control the appearance of the diff
     *
     */
    public function new(align: Alignment, flags: CompareFlags) {
        this.align = align;
        this.flags = flags;
        builder = null;
        preserve_columns = false;
    }

    /**
     *
     * If you wish to customize how diff cells are generated,
     * call this prior to calling `hilite()`.
     *
     * @param builder hooks to generate custom cells
     *
     */
    public function setCellBuilder(builder: CellBuilder) {
        this.builder = builder;
    }

    private function getSeparator(t: Table,
                                 t2: Table, root: String) : String {
        var sep : String = root;
        var w : Int = t.width;
        var h : Int = t.height;
        var view : View = t.getCellView();
        for (y in 0...h) {
            for (x in 0...w) {
                var txt : String = view.toString(t.getCell(x,y));
                if (txt==null) continue;
                while (txt.indexOf(sep)>=0) {
                    sep = "-" + sep;
                }
            }
        }
        if (t2!=null) {
            w = t2.width;
            h = t2.height;
            for (y in 0...h) {
                for (x in 0...w) {
                    var txt : String = view.toString(t2.getCell(x,y));
                    if (txt==null) continue;
                    while (txt.indexOf(sep)>=0) {
                        sep = "-" + sep;
                    }
                }
            }
        }
        return sep;
    }

    private function isReordered(m: Map<Int,Unit>, ct: Int) : Bool {
        var reordered : Bool = false;
        var l : Int = -1;
        var r : Int = -1;
        for (i in 0...ct) {
            var unit : Unit = m.get(i);
            if (unit==null) continue;
            if (unit.l>=0) {
                if (unit.l<l) {
                    reordered = true;
                    break;
                }
                l = unit.l;
            }
            if (unit.r>=0) {
                if (unit.r<r) {
                    reordered = true;
                    break;
                }
                r = unit.r;
            }
        }
        return reordered;
    }


    private function spreadContext(units: Array<Unit>, 
                                   del: Int,
                                   active: Array<Int>) : Void {
        if (del>0 && active != null) {
            // forward
            var mark : Int = -del-1;
            var skips : Int = 0;
            for (i in 0...units.length) {
                if (active[i]==-3) {
                    // inserted/deleted row that is not to be shown, ignore
                    skips++;
                    continue;
                }
                if (active[i]==0||active[i]==3) {
                    if (i-mark<=del+skips) {
                        active[i] = 2;
                    } else if (i-mark==del+1+skips) {
                        active[i] = 3;
                    }
                } else if (active[i]==1) {
                    mark = i;
                    skips = 0;
                }
            }
            
            // reverse
            mark = units.length + del + 1;
            skips = 0;
            for (j in 0...units.length) {
                var i : Int = units.length-1-j;
                if (active[i]==-3) {
                    // inserted/deleted row that is not to be shown, ignore
                    skips++;
                    continue;
                }
                if (active[i]==0||active[i]==3) {
                    if (mark-i<=del+skips) {
                        active[i] = 2;
                    } else if (mark-i==del+1+skips) {
                        active[i] = 3;
                    }
                } else if (active[i]==1) {
                    mark = i;
                    skips = 0;
                }
            }
        }
    }

    private function setIgnore(ignore: Map<String,Bool>,
                               idx_ignore: Map<Int,Bool>,
                               tab: Table,
                               r_header: Int) : Void {
        var v = tab.getCellView();
        if (tab.height>=r_header) {
            for (i in 0...tab.width) {
                var name = v.toString(tab.getCell(i,r_header));
                if (!ignore.exists(name)) continue;
                idx_ignore.set(i,true);
            }
        }
    }

    private function countActive(active: Array<Int>) : Int {
        var ct = 0;
        var showed_dummy = false;
        for (i in 0...active.length) {
            var publish = active[i]>0;
            var dummy = active[i]==3;
            if (dummy&&showed_dummy) continue;
            if (!publish) continue;
            showed_dummy = dummy;
            ct++;
        }
        return ct;
    }

    private function reset() {
        has_parent = false;
        rp_header = ra_header = rb_header = 0;
        is_index_p = new Map<Int,Bool>();
        is_index_a = new Map<Int,Bool>();
        is_index_b = new Map<Int,Bool>();
        row_map = new Map<Int,Unit>();
        col_map = new Map<Int,Unit>();
        show_rc_numbers = false;
        row_moves = null;
        col_moves = null;
        allow_insert = allow_delete = allow_update = allow_column = true;
        sep = "";
        conflict_sep = "";
        top_line_done = false;
        diff_found = false;
        schema_diff_found = false;
        row_deletes = 0;
        row_inserts = 0;
        row_updates = 0;
        row_reorders = 0;
        col_deletes = 0;
        col_inserts = 0;
        col_updates = 0;
        col_renames = 0;
        col_reorders = 0;
        column_units_updated = new Map<Int,Bool>();
    }

    private function setupTables() : Void {
        order = align.toOrder();
        row_units = order.getList();
        has_parent = (align.reference != null);
        if (has_parent) {
            p = align.getSource();
            a = align.reference.getTarget();
            b = align.getTarget();
            rp_header = align.reference.meta.getSourceHeader();
            ra_header = align.reference.meta.getTargetHeader();
            rb_header = align.meta.getTargetHeader();
            if (align.getIndexColumns()!=null) {
                for (p2b in align.getIndexColumns()) {
                    if (p2b.l>=0) is_index_p.set(p2b.l,true);
                    if (p2b.r>=0) is_index_b.set(p2b.r,true);
                }
            }
            if (align.reference.getIndexColumns()!=null) {
                for (p2a in align.reference.getIndexColumns()) {
                    if (p2a.l>=0) is_index_p.set(p2a.l,true);
                    if (p2a.r>=0) is_index_a.set(p2a.r,true);
                }
            }
        } else {
            a = align.getSource();
            b = align.getTarget();
            p = a;
            ra_header = align.meta.getSourceHeader();
            rp_header = ra_header;
            rb_header = align.meta.getTargetHeader();
            if (align.getIndexColumns()!=null) {
                for (a2b in align.getIndexColumns()) {
                    if (a2b.l>=0) is_index_a.set(a2b.l,true);
                    if (a2b.r>=0) is_index_b.set(a2b.r,true);
                }
            }
        }

        allow_insert = flags.allowInsert();
        allow_delete = flags.allowDelete();
        allow_update = flags.allowUpdate();
        allow_column = flags.allowColumn();

        var common = a;
        if (common==null) common = b;
        if (common==null) common = p;
        v = common.getCellView();
        builder.setView(v);

        nested = false;
        var meta = common.getMeta();
        if (meta!=null) {
            nested = meta.isNested();
        }
        nesting_present = false;
    }

    private function scanActivity() {
        active_row = new Array<Int>();
        active_column = null;
        if (!flags.show_unchanged) {
            for (i in 0...row_units.length) {
                // flip assignment order for php efficiency :-)
                active_row[row_units.length-1-i] = 0;
            }
        }

        if (!flags.show_unchanged_columns) {
            active_column = new Array<Int>();
            for (i in 0...column_units.length) {
                var v : Int = 0;
                var unit : Unit = column_units[i];
                if (unit.l>=0 && is_index_a.get(unit.l)) v = 1;
                if (unit.r>=0 && is_index_b.get(unit.r)) v = 1;
                if (unit.p>=0 && is_index_p.get(unit.p)) v = 1;
                active_column[i] = v;
            }
        }
    }


    private function setupColumns() {
        var column_order : Ordering = align.meta.toOrder();
        column_units = column_order.getList();

        var ignore = flags.getIgnoredColumns();
        if (ignore!=null) {
            var p_ignore = new Map<Int,Bool>();
            var a_ignore = new Map<Int,Bool>();
            var b_ignore = new Map<Int,Bool>();
            setIgnore(ignore,p_ignore,p,rp_header);
            setIgnore(ignore,a_ignore,a,ra_header);
            setIgnore(ignore,b_ignore,b,rb_header);

            var ncolumn_units = new Array<Unit>();
            for (j in 0...column_units.length) {
                var cunit : Unit = column_units[j];
                if (p_ignore.exists(cunit.p)||
                    a_ignore.exists(cunit.l)||
                    b_ignore.exists(cunit.r)) continue;
                ncolumn_units.push(cunit);
            }
            column_units = ncolumn_units;
        }
    }

    private function setupMoves() {
        if (flags.ordered) {
            row_moves = new Map<Int,Int>();
            var moves : Array<Int> = Mover.moveUnits(row_units);
            for (i in 0...moves.length) {
                row_moves[moves[i]] = i;
            }
            col_moves = new Map<Int,Int>();
            moves = Mover.moveUnits(column_units);
            for (i in 0...moves.length) {
                col_moves[moves[i]] = i;
            }
        }
    }

    private function scanSchema() {
        schema = new Array<String>();
        have_schema = false;
        for (j in 0...column_units.length) {
            var cunit : Unit = column_units[j];
            var reordered : Bool = false;
            
            if (flags.ordered) {
                if (col_moves.exists(j)) {
                    reordered = true;
                }
                if (reordered) show_rc_numbers = true;
            }

            var act : String = "";
            if (cunit.r>=0 && cunit.lp()==-1) {
                have_schema = true;
                act = "+++";
                if (active_column!=null) {
                    if (allow_column) {
                        active_column[j] = 1;
                    }
                }
                if (allow_column) {
                    col_inserts++;
                }
            }
            if (cunit.r<0 && cunit.lp()>=0) {
                have_schema = true;
                act = "---";
                if (active_column!=null) {
                    if (allow_column) {
                        active_column[j] = 1;
                    }
                }
                if (allow_column) {
                    col_deletes++;
                }
            }
            if (cunit.r>=0 && cunit.lp()>=0) {
                if (p.height>=rp_header && b.height>=rb_header) {
                    var pp : Dynamic = p.getCell(cunit.lp(),rp_header);
                    var bb : Dynamic = b.getCell(cunit.r,rb_header);
                    if (!isEqual(v,pp,bb)) {
                        have_schema = true;
                        act = "(";
                        act += v.toString(pp);
                        act += ")";
                        if (active_column!=null) {
                            active_column[j] = 1;
                            col_renames++;
                        }
                    }
                }
            }
            if (reordered) {
                act = ":" + act;
                have_schema = true;
                if (active_column!=null) active_column = null; // bail
                col_reorders++;
            }

            schema.push(act);
        }
    }

    private function checkRcNumbers(w: Int, h: Int) {
        // add row/col numbers?
        if (!show_rc_numbers) {
            if (flags.always_show_order) {
                show_rc_numbers = true;
            } else if (flags.ordered) {
                show_rc_numbers = isReordered(row_map,h);
                if (!show_rc_numbers) {
                    show_rc_numbers = isReordered(col_map,w);
                }
            }
        }
    }

    private function addRcNumbers(output: Table) : Int {
        var admin_w : Int = 1;
        if (show_rc_numbers&&!flags.never_show_order) {
            admin_w++;
            var target : Array<Int> = new Array<Int>();
            for (i in 0...output.width) {
                target.push(i+1);
            }
            output.insertOrDeleteColumns(target,output.width+1);

            for (i in 0...output.height) {
                var unit : Unit = row_map.get(i);
                if (unit==null) {
                    output.setCell(0,i,"");
                    continue;
                }
                output.setCell(0,i,builder.links(unit,true));
            }
            target = new Array<Int>();
            for (i in 0...output.height) {
                target.push(i+1);
            }
            output.insertOrDeleteRows(target,output.height+1);
            for (i in 1...output.width) {
                var unit : Unit = col_map.get(i-1);
                if (unit==null) {
                    output.setCell(i,0,"");
                    continue;
                }
                output.setCell(i,0,builder.links(unit,false));
            }
            output.setCell(0,0,builder.marker("@:@"));
        }
        return admin_w;
    }

    private function elideColumns(output: Table, admin_w: Int) {
        if (active_column!=null) {
            var all_active : Bool = true;
            for (i in 0...active_column.length) {
                if (active_column[i]==0) {
                    all_active = false;
                    break;
                }
            }
            if (!all_active) {
                var fate : Array<Int> = new Array<Int>();
                for (i in 0...admin_w) {
                    fate.push(i);
                }
                var at : Int = admin_w;
                var ct : Int = 0;
                var dots : Array<Int> = new Array<Int>();
                for (i in 0...active_column.length) {
                    var off : Bool = (active_column[i]==0);
                    ct = off ? (ct+1) : 0;
                    if (off && ct>1) {
                        fate.push(-1);
                    } else {
                        if (off) dots.push(at);
                        fate.push(at);
                        at++;
                    }
                }
                output.insertOrDeleteColumns(fate,at);
                for (d in dots) {
                    for (j in 0...output.height) {
                        output.setCell(d,j,builder.marker("..."));
                    }
                }
            }
        }
    }

    private function addSchema(output: Table) {
        if (have_schema) {
            var at : Int = output.height;
            output.resize(column_units.length+1,at+1);
            output.setCell(0,at,builder.marker("!"));
            for (j in 0...column_units.length) {
                output.setCell(j+1,at,v.toDatum(schema[j]));
            }
            schema_diff_found = true;
        }
    }

    private function addHeader(output: Table) {
        if (flags.always_show_header) {
            var at : Int = output.height;
            output.resize(column_units.length+1,at+1);
            output.setCell(0,at,builder.marker("@@"));
            for (j in 0...column_units.length) {
                var cunit : Unit = column_units[j];
                if (cunit.r>=0) {
                    if (b.height!=0) {
                        output.setCell(j+1,at,
                                       b.getCell(cunit.r,rb_header));
                    }
                } else if (cunit.l>=0) {
                    if (a.height!=0) {
                        output.setCell(j+1,at,
                                       a.getCell(cunit.l,ra_header));
                    }
                } else if (cunit.lp()>=0) {
                    if (p.height!=0) {
                        output.setCell(j+1,at,
                                       p.getCell(cunit.lp(),rp_header));
                    }
                }
                col_map.set(j+1,cunit);
            }
            top_line_done = true;
        }
    }

    private function checkMeta(t: Table, meta: Table) : Bool {
        if (meta==null) {
            return false;
        }
        if (t==null) {
            return (meta.width==1 && meta.height==1);
        }
        if (meta.width!=t.width+1) return false;
        if (meta.width==0||meta.height==0) return false;
        return true;
    }

    private function getMetaTable(t: Table) : Table {
        if (t==null) {
            var result = new SimpleTable(1,1);
            result.setCell(0,0,"@");
            return result;
        }
        var meta = t.getMeta();
        if (meta==null) return null;
        return meta.asTable();
    }

    private function addMeta(output: Table) : Bool {
        if (a==null&&b==null&&p==null) return false;
        if (!flags.show_meta) return false;

        var a_meta : Table = getMetaTable(a);
        var b_meta : Table = getMetaTable(b);
        var p_meta : Table = getMetaTable(p);
        if (!checkMeta(a,a_meta)) return false;
        if (!checkMeta(b,b_meta)) return false;
        if (!checkMeta(p,p_meta)) return false;

        // Crude method: create a temporary table, write meta diff to it, copy as needed.

        var meta_diff = new SimpleTable(0,0);
        var meta_flags = new CompareFlags();
        meta_flags.addPrimaryKey("@@");
        meta_flags.addPrimaryKey("@");
        meta_flags.unchanged_column_context = 65536; // FIXME - want infinite
        meta_flags.unchanged_context = 0;
        var meta_align = Coopy.compareTables3((a_meta==p_meta)?null:p_meta,a_meta,b_meta,meta_flags).align();
        var td = new TableDiff(meta_align,meta_flags);
        td.preserve_columns = true;
        td.hilite(meta_diff);

        if (td.hasDifference()||td.hasSchemaDifference()) {
            var h = output.height;
            var dh = meta_diff.height;
            var offset = td.hasSchemaDifference()?2:1;
            output.resize(output.width,h+dh-offset);
            var v = meta_diff.getCellView();
            for (y in offset...dh) {
                for (x in 1...meta_diff.width) {
                    var c = meta_diff.getCell(x,y);
                    if (x==1) {
                        c = "@" + v.toString(c) + "@" + v.toString(meta_diff.getCell(0,y));
                    }
                    output.setCell(x-1,h+y-offset,c);
                }
            }
            if (active_column!=null) {
                if (td.active_column.length == meta_diff.width) {
                    // if not equal, there was no change
                    for (i in 1...meta_diff.width) {
                        if (td.active_column[i]>=0) {
                            active_column[i-1] = 1;
                        }
                    }
                }
            }
        }

        return false;
    }

    private function refineActivity() {
        spreadContext(row_units,flags.unchanged_context,active_row);
        spreadContext(column_units,flags.unchanged_column_context,
                      active_column);
        if (active_column!=null) {
            for (i in 0...column_units.length) {
                if (active_column[i]==3) {
                    active_column[i] = 0;
                }
            }
        }
    }

    private function normalizeString(v: View, str: Dynamic) : String {
        if (str==null) return str;
        if (!(flags.ignore_whitespace||flags.ignore_case)) {
            return str;
        }
        var txt = v.toString(str);
        if (flags.ignore_whitespace) {
            txt = StringTools.trim(txt);
        }
        if (flags.ignore_case) {
            txt = txt.toLowerCase();
        }
        return txt;
    }

    private function isEqual(v: View, aa: Dynamic, bb: Dynamic) : Bool {
        // Check if we need to apply an exception for comparing floating
        // point numbers.
        if (flags.ignore_epsilon > 0) {
            var fa = Std.parseFloat(aa);
            if (!Math.isNaN(fa)) {
                var fb = Std.parseFloat(bb);
                if (!Math.isNaN(fb)) {
                    if (Math.abs(fa - fb) < flags.ignore_epsilon) {
                        return true;
                    }
                }
            }
        }
        if (flags.ignore_whitespace || flags.ignore_case) {
            return normalizeString(v,aa) == normalizeString(v,bb);
        }
        return v.equals(aa,bb);
    }

    private function checkNesting(v: View,
                                  have_ll: Bool, ll: Dynamic,
                                  have_rr: Bool, rr: Dynamic,
                                  have_pp: Bool, pp: Dynamic,
                                  x: Int, y: Int) : Array<Dynamic> {
        var all_tables = true;
        if (have_ll) all_tables = all_tables && v.isTable(ll);
        if (have_rr) all_tables = all_tables && v.isTable(rr);
        if (have_pp) all_tables = all_tables && v.isTable(pp);
        if (!all_tables) return [ll,rr,pp];
        // life just got interesting!
        var ll_table : Table = null;
        var rr_table : Table = null;
        var pp_table : Table = null;
        if (have_ll) ll_table = v.getTable(ll);
        if (have_rr) rr_table = v.getTable(rr);
        if (have_pp) pp_table = v.getTable(pp);
        var compare = false;
        var comp = new TableComparisonState();
        comp.a = ll_table;
        comp.b = rr_table;
        comp.p = pp_table;
        comp.compare_flags = flags;
        comp.getMeta();
        var key = null;
        if (comp.a_meta!=null) {
            key = comp.a_meta.getName();
        }
        if (key == null && comp.b_meta!=null) {
            key = comp.b_meta.getName();
        }
        if (key == null) {
            key = x + "_" + y;
        }
        if (align.comp != null) {
            if (align.comp.children == null) {
                align.comp.children = new Map<String, TableComparisonState>();
                align.comp.child_order = new Array<String>();
                compare = true;
            } else {
                compare = !align.comp.children.exists(key);
            }
        }
        if (compare) {
            nesting_present = true;
            align.comp.children.set(key,comp);
            align.comp.child_order.push(key);
            var ct = new CompareTable(comp);
            ct.align();
        } else {
            comp = align.comp.children.get(key);
        }
        // could at this point check whether there are differences
        var ll_out : String = null;
        var rr_out : String = null;
        var pp_out : String = null;
        if (comp.alignment.isMarkedAsIdentical() || (have_ll&&!have_rr) || (have_rr&&!have_ll)) {
            ll_out = "[" + key + "]";
            rr_out = ll_out;
            pp_out = ll_out;
        } else {
            if (ll!=null) {
                ll_out = "[a." + key + "]";
            }
            if (rr!=null) {
                rr_out = "[b." + key + "]";
            }
            if (pp!=null) {
                pp_out = "[p." + key + "]";
            }
        }
        return [ll_out, rr_out, pp_out];
    }

    /**
     *
     * Generate diff for given l/r/p row unit #i.
     *
     * Relies on state of:
     *   column_units, tables a/b/p, flags, view v,
     *   allow_update, active_column, sep, conflict_sep, publish, active_row
     *
     * @param unit the index of the row to compare in each table
     * @param output where to store the diff
     * @param at the current row location in the output table
     * @param i the index of the row unit
     *
     */
    private function scanRow(unit: Unit, output: Table, at: Int, i: Int, out: Int) {
        var row_update : Bool = false;
        for (j in 0...column_units.length) {
            var cunit : Unit = column_units[j];
            var pp : Dynamic = null;
            var ll : Dynamic = null;
            var rr : Dynamic = null;
            var dd : Dynamic = null;
            var dd_to : Dynamic = null;
            var have_dd_to : Bool = false;
            var dd_to_alt : Dynamic = null;
            var have_dd_to_alt : Bool = false;
            var have_pp : Bool = false;
            var have_ll : Bool = false;
            var have_rr : Bool = false;
            if (cunit.p>=0 && unit.p>=0) {
                pp = p.getCell(cunit.p,unit.p);
                have_pp = true;
            }
            if (cunit.l>=0 && unit.l>=0) {
                ll = a.getCell(cunit.l,unit.l);
                have_ll = true;
            }
            if (cunit.r>=0 && unit.r>=0) {
                rr = b.getCell(cunit.r,unit.r);
                have_rr = true;
                if ((have_pp ? cunit.p : cunit.l)<0) {
                    if (rr != null) {
                        if (v.toString(rr) != "") {
                            if (allow_column) {
                                have_addition = true;
                            }
                        }
                    }
                }
            }

            // if dealing with a nested table, now have ll rr pp
            // should do something smart like starting a subcomparison
            // (or enqueuing, but possible we need results now)
            if (nested) {
                var ndiff = checkNesting(v,
                                         have_ll,ll,
                                         have_rr,rr,
                                         have_pp,pp,
                                         i, j);
                ll = ndiff[0];
                rr = ndiff[1];
                pp = ndiff[2];
            }

            // for now, just interested in p->r
            if (have_pp) {
                if (!have_rr) {
                    dd = pp;
                } else {
                    // have_pp, have_rr
                    if (isEqual(v,pp,rr)) {
                        dd = ll;
                    } else {
                        // rr is different
                        dd = pp;
                        dd_to = rr;
                        have_dd_to = true;

                        if (!isEqual(v,pp,ll)) {
                            if (!isEqual(v,pp,rr)) {
                                dd_to_alt = ll;
                                have_dd_to_alt = true;
                            }
                        }
                    }
                }
            } else if (have_ll) {
                if (!have_rr) {
                    dd = ll;
                } else {
                    if (isEqual(v,ll,rr)) {
                        dd = ll;
                    } else {
                        // rr is different
                        dd = ll;
                        dd_to = rr;
                        have_dd_to = true;
                    }
                }
            } else {
                dd = rr;
            }

            var cell : Dynamic = dd;
            if (have_dd_to&&((dd!=null&&allow_update)||allow_column)) {
                if (!row_update) {
                    if (out==0) row_updates++;
                    row_update = true;
                }
                if (active_column!=null) {
                    active_column[j] = 1;
                }
                // modification: x -> y
                if (sep=="") {
                    if (builder.needSeparator()) {
                        // strictly speaking getSeparator(a,null,..)
                        // would be ok - but very confusing
                        sep = getSeparator(a,b,"->");
                        builder.setSeparator(sep);
                    } else {
                        sep = "->";
                    }
                }
                var is_conflict : Bool = false;
                if (have_dd_to_alt) {
                    if (!isEqual(v,dd_to,dd_to_alt)) {
                        is_conflict = true;
                    }
                }
                if (!is_conflict) {
                    cell = builder.update(dd,dd_to);
                    if (sep.length>act.length) {
                        act = sep;
                    }
                } else {
                    if (conflict_sep=="") {
                        if (builder.needSeparator()) {

                            conflict_sep = getSeparator(p,a,"!") + sep;
                            builder.setConflictSeparator(conflict_sep);
                        } else {
                            conflict_sep = "!->";
                        }
                    }
                    cell = builder.conflict(dd,dd_to_alt,dd_to);
                    act = conflict_sep;
                }
                if (!column_units_updated.exists(j)) {
                    column_units_updated.set(j,true);
                    col_updates++;
                }
            }
            if (act == "" && have_addition) {
                act = "+";
            }
            if (act == "+++") {
                if (have_rr) {
                    if (active_column!=null) {
                        active_column[j] = 1;
                    }
                }
            }
            if (publish) {
                if (active_column==null || active_column[j]>0) {
                    output.setCell(j+1,at,cell);
                }
            }
        }

        if (publish) {
            output.setCell(0,at,builder.marker(act));
            row_map.set(at,unit);
        }

        if (act!="") {
            diff_found = true;
            if (!publish) {
                if (active_row!=null) {
                    active_row[i] = 1;
                }
            }
        }
    }

    /**
     *
     * Generate a highlighter diff.
     * @param output the table in which to place the diff - it can then
     * be converted to html using `DiffRender`
     * @return true on success
     *
     */
    public function hilite(output: Table) : Bool { 
        output = Coopy.tablify(output); // accept native tables
        return hiliteSingle(output);
    }

    private function hiliteSingle(output: Table) : Bool { 
        if (!output.isResizable()) return false;
        if (builder==null) {
            if (flags.allow_nested_cells) {
                builder = new NestedCellBuilder();
            } else {
                builder = new FlatCellBuilder(flags);
            }
        }
        output.resize(0,0);
        output.clear();

        reset();
        setupTables();
        setupColumns();
        setupMoves();
        scanActivity();
        scanSchema();
        addSchema(output);
        addHeader(output);
        addMeta(output);

        // If we are omitting unchanged rows/columns, we need two passes,
        // the first to compute what has changed, and the second to
        // set the resize the output appropriately and fill it.
        var outer_reps_needed : Int = 
            (flags.show_unchanged&&flags.show_unchanged_columns) ? 1 : 2;

#if php
        // Under PHP, it is going to be better to repeat the loop,
        // so we don't end up resizing our table bit by bit - this is 
        // super slow under PHP for large tables
        outer_reps_needed = 2;
#end

        var output_height : Int = output.height;
        var output_height_init : Int = output.height;
        // If we are dropping unchanged rows/cols, we repeat this loop twice.
        for (out in 0...outer_reps_needed) {
            if (out==1) {
                refineActivity();
                var rows : Int = countActive(active_row)+output_height_init;
                if (top_line_done) rows--;
                output_height = output_height_init;
                if (rows>output.height) {
                    output.resize(column_units.length+1,rows);
                }
            }

            var showed_dummy : Bool = false;
            var l : Int = -1;
            var r : Int = -1;
            for (i in 0...row_units.length) {
                var unit : Unit = row_units[i];
                var reordered : Bool = false;

                if (flags.ordered) {
                    if (row_moves.exists(i)) {
                        reordered = true;
                    }
                    if (reordered) show_rc_numbers = true;
                }

                if (unit.r<0 && unit.l<0) continue;
                
                if (unit.r==0 && unit.lp()<=0 && top_line_done) continue;

                publish = flags.show_unchanged;
                var dummy : Bool = false;
                if (out==1) {
                    var value: Null<Int> = active_row[i];
                    publish = value!=null && value>0;
                    dummy = value!=null && value==3;
                    if (dummy&&showed_dummy) continue;
                    if (!publish) continue;
                }

                if (!dummy) showed_dummy = false;

                var at : Int = output_height;
                if (publish) {
                    output_height++;
                    if (output.height<output_height) {
                        output.resize(column_units.length+1,output_height);
                    }
                }
                if (dummy) {
                    for (j in 0...(column_units.length+1)) {
                        output.setCell(j,at,v.toDatum("..."));
                    }
                    showed_dummy = true;
                    continue;
                }
                
                have_addition = false;
                var skip : Bool = false;
                
                act = "";
                if (reordered) {
                    act = ":";
                    if (out==0) row_reorders++;
                }

                if (unit.p<0 && unit.l<0 && unit.r>=0) {
                    if (!allow_insert) skip = true;
                    act = "+++";
                    if (out==0 && !skip) row_inserts++;
                }
                if ((unit.p>=0||!has_parent) && unit.l>=0 && unit.r<0) {
                    if (!allow_delete) skip = true;
                    act = "---";
                    if (out==0 && !skip) row_deletes++;
                }

                if (skip) {
                    if (!publish) {
                        if (active_row!=null) {
                            active_row[i] = -3;
                        }
                    }
                    continue;
                }

                scanRow(unit,output,at,i,out);
            }
        }

        checkRcNumbers(output.width,output.height);

        var admin_w : Int = addRcNumbers(output);
        if (!preserve_columns) elideColumns(output,admin_w);

        return true;
    }


    // multi-table version
    public function hiliteWithNesting(output: Tables) : Bool {
        var base = output.add("base");
        var result = hiliteSingle(base);
        if (!result) return false;
        if (align.comp==null) return true;
        var order = align.comp.child_order;
        if (order==null) return true;
        output.alignment = align;
        for (name in order) {
            var child = align.comp.children.get(name);
            var alignment = child.alignment;
            if (alignment.isMarkedAsIdentical()) {
                align.comp.children.set(name,null);
                continue;
            }
            var td = new TableDiff(alignment,flags);
            var child_output = output.add(name);
            result = result && td.hiliteSingle(child_output);
        }
        return result;
    }

    /**
     *
     * @return true if a difference was found during call to `hilite()`
     *
     */
    public function hasDifference() : Bool {
        return diff_found;
    }

    /**
     *
     * @return true if a schema difference was found during call to `hilite()`
     *
     */
    public function hasSchemaDifference() : Bool {
        return schema_diff_found;
    }

    public function isNested() : Bool {
        return nesting_present;
    }

    public function getComparisonState() : TableComparisonState {
        if (align==null) return null;
        return align.comp;
    }

    /**
     *
     * Get statistics of the diff - number of rows deleted, updated,
     * etc.
     *
     */
    public function getSummary() : DiffSummary {
        var ds = new DiffSummary();
        ds.row_deletes = row_deletes;
        ds.row_inserts = row_inserts;
        ds.row_updates = row_updates;
        ds.row_reorders = row_reorders;
        ds.col_deletes = col_deletes;
        ds.col_inserts = col_inserts;
        ds.col_updates = col_updates;
        ds.col_renames = col_renames;
        ds.col_reorders = col_reorders;
        ds.row_count_initial_with_header = align.getSource().height;
        ds.row_count_final_with_header = align.getTarget().height;
        ds.row_count_initial = align.getSource().height - align.getSourceHeader() - 1;
        ds.row_count_final = align.getTarget().height - align.getTargetHeader() - 1;
        ds.col_count_initial = align.getSource().width;
        ds.col_count_final = align.getTarget().width;
        ds.different = (row_deletes + row_inserts + row_updates + row_reorders +
                        col_deletes + col_inserts + col_updates + col_renames +
                        col_reorders) > 0;
        return ds;
    }
}

