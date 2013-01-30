// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

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
        var p2l : Comparison = new Comparison();
        var p2r : Comparison = new Comparison();
        p2l.a = ws.tparent;
        p2l.b = ws.tlocal;
        p2r.a = ws.tparent;
        p2r.b = ws.tremote;
        var cmp : CompareTable = new CompareTable();
        cmp.compare(p2l);
        cmp.compare(p2r);

        var c : Change = new Change();
        c.parent = ws.parent;
        c.local = ws.local;
        c.remote = ws.remote;
        if (p2l.equal && (!p2r.equal)) {
            c.mode = REMOTE_CHANGE;
        } else if ((!p2l.equal) && p2r.equal) {
            c.mode = LOCAL_CHANGE;
        } else if ((!p2l.equal) && (!p2r.equal)) {
            // maybe same change?
            var l2r : Comparison = new Comparison();
            l2r.a = ws.tlocal;
            l2r.b = ws.tremote;
            cmp.compare(l2r);
            if (l2r.equal) {
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
