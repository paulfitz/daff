// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class TableDiff {
    private var align : Alignment;
    private var flags : CompareFlags;

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
                    while (txt.indexOf(sep)>=0) {
                        sep = "-" + sep;
                    }
                }
            }
        }
        return sep;
    }

    public function quoteForDiff(v: View, d: Datum) : String {
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
        /*
        if (str.indexOf("NULL")>=0) {
            trace("Looking at " + str + " got score " + score);
        }
        */
        if (str.substr(score)==nil) {
            str = "_" + str;
        }
        return str;
    }

    public function hilite(output: Table) : Bool { 
        if (!output.isResizable()) return false;
        output.resize(0,0);
        output.clear();

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

        var outer_reps_needed : Int = flags.show_unchanged ? 1 : 2;

        var v : View = a.getCellView();
        var sep : String = "";
        var conflict_sep : String = "";

        var schema : Array<String> = new Array<String>();
        var have_schema : Bool = false;
        for (j in 0...column_units.length) {
            var cunit : Unit = column_units[j];
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
                    var aa : Datum = a.getCell(cunit.lp(),ra_header);
                    var bb : Datum = b.getCell(cunit.r,rb_header);
                    if (!v.equals(aa,bb)) {
                        have_schema = true;
                        act = "(";
                        act += v.toString(aa);
                        act += ")";
                    }
                }
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
            }
            top_line_done = true;
        }

        var active : Array<Int> = new Array<Int>();
        if (!flags.show_unchanged) {
            for (i in 0...units.length) {
                active[i] = 0;
            }
        }

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
            for (i in 0...units.length) {
                var unit : Unit = units[i];
                
                if (unit.r<0 && unit.l<0) continue;
                
                if (unit.r==0 && unit.lp()==0 && top_line_done) continue;

                var act : String = "";

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
                    var pp : Datum = null;
                    var ll : Datum = null;
                    var rr : Datum = null;
                    var dd : Datum = null;
                    var dd_to : Datum = null;
                    var have_dd_to : Bool = false;
                    var dd_to_alt : Datum = null;
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
                            sep = getSeparator(a,null,"->");
                        }
                        if (!have_dd_to_alt) {
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

                if (publish) output.setCell(0,at,v.toDatum(act));
                if (act!="") {
                    if (!publish) {
                        if (active!=null) {
                            active[i] = 1;
                        }
                    }
                }
            }
        }
        return true;
    }


    public function test() : Report { 
        var report : Report = new Report();
        var order : Ordering = align.toOrder();
        var units : Array<Unit> = order.getList();
        var has_parent : Bool = (align.reference != null);
        var a : Table;
        var b : Table;
        var p : Table;
        if (has_parent) {
            p = align.getSource();
            a = align.reference.getTarget();
            b = align.getTarget();
        } else {
            a = align.getSource();
            b = align.getTarget();
            p = a;
        }
        
        for (i in 0...units.length) {
            var unit : Unit = units[i];
            if (unit.p<0 && unit.l<0 && unit.r>=0) {
                report.changes.push(new Change("inserted row r:" + unit.r));
            }
            if ((unit.p>=0||!has_parent) && unit.l>=0 && unit.r<0) {
                report.changes.push(new Change("deleted row l:" + unit.l));
            }
            if (unit.l>=0&&unit.r>=0) {
                var mod : Bool = false;
                var av : View = a.getCellView();
                for (j in 0...a.width) {
                    // ...
                }
            }
        }
        // we don't look at any values yet
        return report;
    }
}

