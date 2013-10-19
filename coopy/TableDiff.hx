// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class TableDiff {
    private var align : Alignment;
    private var flags : CompareFlags;
    private var l_prev : Int;
    private var r_prev : Int;

    public function new(align: Alignment, flags: CompareFlags) {
        this.align = align;
        this.flags = flags;
    }

    public function getSeparator(t: Table,
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

    public function quoteForDiff(v: View, d: Dynamic) : String {
        var nil : String = "NULL";
        if (v.equals(d,null)) {
            return nil;
        }
        var str : String = v.toString(d);
        var score : Int = 0;
        for (i in 0...str.length) {
            if (str.charCodeAt(score)!='_'.code) break;
            score++;
        }
        if (str.substr(score)==nil) {
            str = "_" + str;
        }
        return str;
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

    private function reportUnit(unit: Unit) : String {
        var txt : String = unit.toString();
        var reordered : Bool = false;
        if (unit.l>=0) {
            if (unit.l<l_prev) {
                reordered = true;
            }
            l_prev = unit.l;
        }
        if (unit.r>=0) {
            if (unit.r<r_prev) {
                reordered = true;
            }
            r_prev = unit.r;
        }
        if (reordered) txt = "[" + txt + "]";
        return txt;
    }

    public function hilite(output: Table) : Bool { 
        if (!output.isResizable()) return false;
        output.resize(0,0);
        output.clear();

        var row_map : Map<Int,Unit> = new Map<Int,Unit>();
        var col_map : Map<Int,Unit> = new Map<Int,Unit>();

        var order : Ordering = align.toOrder();
        var units : Array<Unit> = order.getList();
        var has_parent : Bool = (align.reference != null);
        var a : Table;
        var b : Table;
        var p : Table;
        var ra_header : Int = 0;
        var rb_header : Int = 0;
        if (has_parent) {
            p = align.getSource();
            a = align.reference.getTarget();
            b = align.getTarget();
            ra_header = align.reference.meta.getTargetHeader();
            rb_header = align.meta.getTargetHeader();
        } else {
            a = align.getSource();
            b = align.getTarget();
            p = a;
            ra_header = align.meta.getSourceHeader();
            rb_header = align.meta.getTargetHeader();
        }

        var column_order : Ordering = align.meta.toOrder();
        var column_units : Array<Unit> = column_order.getList();

        var show_rc_numbers : Bool = false;
        var row_moves : Map<Int,Int> = null;
        var col_moves : Map<Int,Int> = null;
        if (flags.ordered) {
            row_moves = new Map<Int,Int>();
            var moves : Array<Int> = Mover.moveUnits(units);
            for (i in 0...moves.length) {
                row_moves[moves[i]] = i;
            }
            col_moves = new Map<Int,Int>();
            moves = Mover.moveUnits(column_units);
            for (i in 0...moves.length) {
                col_moves[moves[i]] = i;
            }
        }

        var outer_reps_needed : Int = flags.show_unchanged ? 1 : 2;

        var v : View = a.getCellView();
        var sep : String = "";
        var conflict_sep : String = "";

        var schema : Array<String> = new Array<String>();
        var have_schema : Bool = false;
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
            }
            if (cunit.r<0 && cunit.lp()>=0) {
                have_schema = true;
                act = "---";
            }
            if (cunit.r>=0 && cunit.lp()>=0) {
                if (a.height>=ra_header && b.height>=rb_header) {
                    var aa : Dynamic = a.getCell(cunit.lp(),ra_header);
                    var bb : Dynamic = b.getCell(cunit.r,rb_header);
                    if (!v.equals(aa,bb)) {
                        have_schema = true;
                        act = "(";
                        act += v.toString(aa);
                        act += ")";
                    }
                }
            }
            if (reordered) {
                act = ":" + act;
                have_schema = true;
            }

            schema.push(act);
        }
        if (have_schema) {
            var at : Int = output.height;
            output.resize(column_units.length+1,at+1);
            output.setCell(0,at,v.toDatum("!"));
            for (j in 0...column_units.length) {
                output.setCell(j+1,at,v.toDatum(schema[j]));
            }
        }

        var top_line_done : Bool = false;
        if (flags.always_show_header) {
            var at : Int = output.height;
            output.resize(column_units.length+1,at+1);
            output.setCell(0,at,v.toDatum("@@"));
            for (j in 0...column_units.length) {
                var cunit : Unit = column_units[j];
                if (cunit.r>=0) {
                    if (b.height>0) {
                        output.setCell(j+1,at,
                                       b.getCell(cunit.r,rb_header));
                    }
                } else if (cunit.lp()>=0) {
                    if (a.height>0) {
                        output.setCell(j+1,at,
                                       a.getCell(cunit.lp(),ra_header));
                    }
                }
                col_map.set(j+1,cunit);
            }
            top_line_done = true;
        }

        var active : Array<Int> = new Array<Int>();
        if (!flags.show_unchanged) {
            for (i in 0...units.length) {
                active[i] = 0;
            }
        }

        // If we are dropping unchanged rows, we repeat this loop twice.
        for (out in 0...outer_reps_needed) {
            if (out==1) {
                var del : Int = flags.unchanged_context;
                if (del>0) {
                    // forward
                    var mark : Int = -del-1;
                    for (i in 0...units.length) {
                        if (active[i]==0||active[i]==3) {
                            if (i-mark<=del) {
                                active[i] = 2;
                            } else if (i-mark==del+1) {
                                active[i] = 3;
                            }
                        } else if (active[i]==1) {
                            mark = i;
                        }
                    }

                    // reverse
                    mark = units.length + del + 1;
                    for (j in 0...units.length) {
                        var i : Int = units.length-1-j;
                        if (active[i]==0||active[i]==3) {
                            if (mark-i<=del) {
                                active[i] = 2;
                            } else if (mark-i==del+1) {
                                active[i] = 3;
                            }
                        } else if (active[i]==1) {
                            mark = i;
                        }
                    }
                }
            }
            var showed_dummy : Bool = false;
            var l : Int = -1;
            var r : Int = -1;
            for (i in 0...units.length) {
                var unit : Unit = units[i];
                var reordered : Bool = false;

                if (flags.ordered) {
                    if (row_moves.exists(i)) {
                        reordered = true;
                    }
                    if (reordered) show_rc_numbers = true;
                }

                if (unit.r<0 && unit.l<0) continue;
                
                if (unit.r==0 && unit.lp()==0 && top_line_done) continue;

                var act : String = "";

                if (reordered) act = ":";

                var publish : Bool = flags.show_unchanged;
                var dummy : Bool = false;
                if (out==1) {
                    publish = active[i]>0;
                    dummy = active[i]==3;
                    if (dummy&&showed_dummy) continue;
                    if (!publish) continue;
                }

                if (!dummy) showed_dummy = false;

                var at : Int = output.height;
                if (publish) {
                    output.resize(column_units.length+1,at+1);
                }

                if (dummy) {
                    for (j in 0...(column_units.length+1)) {
                        output.setCell(j,at,v.toDatum("..."));
                        showed_dummy = true;
                    }
                    continue;
                }
                
                var have_addition : Bool = false;
                
                if (unit.p<0 && unit.l<0 && unit.r>=0) {
                    act = "+++";
                }
                if ((unit.p>=0||!has_parent) && unit.l>=0 && unit.r<0) {
                    act = "---";
                }
                
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
                                    have_addition = true;
                                }
                            }
                        }
                    }

                    // for now, just interested in p->r
                    if (have_pp) {
                        if (!have_rr) {
                            dd = pp;
                        } else {
                            // have_pp, have_rr
                            if (v.equals(pp,rr)) {
                                dd = pp;
                            } else {
                                // rr is different
                                dd = pp;
                                dd_to = rr;
                                have_dd_to = true;

                                if (!v.equals(pp,ll)) {
                                    if (!v.equals(pp,rr)) {
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
                            if (v.equals(ll,rr)) {
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

                    var txt : String = null;
                    if (have_dd_to) {
                        txt = quoteForDiff(v,dd);
                        // modification: x -> y
                        if (sep=="") {
                            // strictly speaking getSeparator(a,null,..)
                            // would be ok - but very confusing
                            sep = getSeparator(a,b,"->");
                        }
                        var is_conflict : Bool = false;
                        if (have_dd_to_alt) {
                            if (!v.equals(dd_to,dd_to_alt)) {
                                is_conflict = true;
                            }
                        }
                        if (!is_conflict) {
                            txt = txt + sep + quoteForDiff(v,dd_to);
                            if (sep.length>act.length) {
                                act = sep;
                            }
                        } else {
                            if (conflict_sep=="") {
                                conflict_sep = getSeparator(p,a,"!") + sep;
                            }
                            txt = txt + 
                                conflict_sep + quoteForDiff(v,dd_to_alt) +
                                conflict_sep + quoteForDiff(v,dd_to);
                            act = conflict_sep;
                        }
                    }
                    if (act == "" && have_addition) {
                        act = "+";
                    }
                    if (publish) {
                        if (txt != null) {
                            output.setCell(j+1,at,v.toDatum(txt));
                        } else {
                            output.setCell(j+1,at,dd);
                        }
                    }
                }

                if (publish) {
                    output.setCell(0,at,v.toDatum(act));
                    row_map.set(at,unit);
                }
                if (act!="") {
                    if (!publish) {
                        if (active!=null) {
                            active[i] = 1;
                        }
                    }
                }
            }
        }

        // add row/col numbers?
        if (!show_rc_numbers) {
            if (flags.always_show_order) {
                show_rc_numbers = true;
            } else if (flags.ordered) {
                show_rc_numbers = isReordered(row_map,output.height);
                if (!show_rc_numbers) {
                    show_rc_numbers = isReordered(col_map,output.width);
                }
            }
        }

        if (show_rc_numbers&&!flags.never_show_order) {
            var target : Array<Int> = new Array<Int>();
            for (i in 0...output.width) {
                target.push(i+1);
            }
            output.insertOrDeleteColumns(target,output.width+1);
            l_prev = -1;
            r_prev = -1;
            for (i in 0...output.height) {
                var unit : Unit = row_map.get(i);
                if (unit==null) continue;
                output.setCell(0,i,reportUnit(unit));
            }
            target = new Array<Int>();
            for (i in 0...output.height) {
                target.push(i+1);
            }
            output.insertOrDeleteRows(target,output.height+1);
            l_prev = -1;
            r_prev = -1;
            for (i in 1...output.width) {
                var unit : Unit = col_map.get(i-1);
                if (unit==null) continue;
                output.setCell(i,0,reportUnit(unit));
            }
            output.setCell(0,0,"@:@");
        }
        return true;
    }
}

