// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

class Compare {
    public function new() : Void {}

    public function compare(parent: ViewedDatum,
                            local: ViewedDatum,
                            remote: ViewedDatum,
                            report: Report) : Bool {
        var ws : Workspace = new Workspace();
        ws.parent = parent;
        ws.local = local;
        ws.remote = remote;
        ws.report = report;
        report.clear();
        if (parent==null||local==null||remote==null) {
            report.changes.push(new Change("only 3-way comparison allowed right now"));
            return false;
        }
        if (parent.hasStructure()||local.hasStructure()||remote.hasStructure()) {
            return compareStructured(ws);
        }
        return comparePrimitive(ws);
    }

    private function compareStructured(ws : Workspace) : Bool {
        ws.tparent = ws.parent.getTable();
        ws.tlocal = ws.local.getTable();
        ws.tremote = ws.remote.getTable();
        if (ws.tparent==null||ws.tlocal==null||ws.tremote==null) {
            ws.report.changes.push(new Change("structured comparisons that include non-tables are not available yet"));
            return false;
        }
        return compareTable(ws);
    }

    private function compareTable(ws : Workspace) : Bool {
        ws.p2l = new TableComparisonState();
        ws.p2r = new TableComparisonState();
        ws.p2l.a = ws.tparent;
        ws.p2l.b = ws.tlocal;
        ws.p2r.a = ws.tparent;
        ws.p2r.b = ws.tremote;
        var cmp : CompareTable = new CompareTable();
        cmp.attach(ws.p2l);
        cmp.attach(ws.p2r);

        var c : Change = new Change();
        c.parent = ws.parent;
        c.local = ws.local;
        c.remote = ws.remote;
        if (ws.p2l.is_equal && (!ws.p2r.is_equal)) {
            c.mode = REMOTE_CHANGE;
        } else if ((!ws.p2l.is_equal) && ws.p2r.is_equal) {
            c.mode = LOCAL_CHANGE;
        } else if ((!ws.p2l.is_equal) && (!ws.p2r.is_equal)) {
            // maybe same change?
            ws.l2r = new TableComparisonState();
            ws.l2r.a = ws.tlocal;
            ws.l2r.b = ws.tremote;
            cmp.attach(ws.l2r);
            if (ws.l2r.is_equal) {
                c.mode = SAME_CHANGE;
            } else {
                c.mode = BOTH_CHANGE;
            }
        } else {
            c.mode = NO_CHANGE;
        }
        if (c.mode != ChangeType.NO_CHANGE) {
            ws.report.changes.push(c);
        }
        return true;
    }

    private function comparePrimitive(ws : Workspace) : Bool {
        // OK we have a simple 3-primitive 3-way comparison.
        var sparent : String = ws.parent.toString();
        var slocal : String = ws.local.toString();
        var sremote : String = ws.remote.toString();
        var c : Change = new Change();
        c.parent = ws.parent;
        c.local = ws.local;
        c.remote = ws.remote;
        if (sparent==slocal && sparent!=sremote) {
            c.mode = REMOTE_CHANGE;
        } else if (sparent==sremote && sparent!=slocal) {
            c.mode = LOCAL_CHANGE;
        } else if (slocal==sremote && sparent!=slocal) {
            c.mode = SAME_CHANGE;
        } else if (sparent!=slocal && sparent!=sremote) {
            c.mode = BOTH_CHANGE;
        } else {
            c.mode = NO_CHANGE;
        }
        if (c.mode != ChangeType.NO_CHANGE) {
            ws.report.changes.push(c);
        }
        return true;
    }
}
