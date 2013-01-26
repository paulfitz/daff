// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class Compare {
    public function new() : Void {}

    public function compare(parent: Datum,
                            local: Datum,
                            remote: Datum,
                            report: Report) : Bool {
        report.changes.push(new Change("toy comparison"));
        if (parent==null||local==null||remote==null) {
            report.changes.push(new Change("starting with 3-way"));
            return false;
        }
        if (parent.bag!=null||local.bag!=null||remote.bag!=null) {
            report.changes.push(new Change("starting with primitives"));
            return false;
        }
        // OK we have a simple 3-primitive 3-way comparison.
        // I play games here to have a javascript-compatible conversion
        // if datum is swapped out with a primitive type.
        var sparent : String = "" + parent;
        var slocal : String = "" + local;
        var sremote : String = "" + remote;
        if (sparent==slocal && sparent!=sremote) {
            report.changes.push(new Change(slocal + " -> " + sremote));
        } else if (sparent==sremote && sparent!=slocal) {
            report.changes.push(new Change("local changed, remote unchanged"));
        }
        return true;
    }
}
