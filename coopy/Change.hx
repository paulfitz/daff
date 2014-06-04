// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class Change {
    // toy
    public var change : String;
    public var parent : ViewedDatum;
    public var local : ViewedDatum;
    public var remote : ViewedDatum;
    public var mode : ChangeType;

    public function new(?txt : String) : Void {
        if (txt!=null) {
            mode = NOTE_CHANGE;
            change = txt;
        } else {
            mode = NO_CHANGE;
        }
    }

    public function getMode() : String {
        return ""+mode;
    }

    public function toString() : String {
        return switch(mode) {
        case NO_CHANGE: "no change";
        case LOCAL_CHANGE: "local change: " + remote + " -> " + local;
        case REMOTE_CHANGE: "remote change: " + local + " -> " + remote;
        case BOTH_CHANGE: "conflicting change: " + parent + " -> " + local + " / " + remote;
        case SAME_CHANGE: "same change: " + parent + " -> " + local + " / " + remote;
        case NOTE_CHANGE: change;
        }
    }
}
