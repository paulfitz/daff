// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
enum ChangeType {
    NO_CHANGE;
    REMOTE_CHANGE;
    LOCAL_CHANGE;
    BOTH_CHANGE;
    SAME_CHANGE;
    NOTE_CHANGE;
}
