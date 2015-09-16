// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:noDoc
class FlatCellBuilder implements CellBuilder {
    private var view : View;
    private var separator : String;
    private var conflict_separator : String;
    private var flags : CompareFlags;

    public function new(flags: CompareFlags) {
        this.flags = flags;
    }

    public function needSeparator() {
        return true;
    }

    public function setSeparator(separator: String) {
        this.separator = separator;
    }

    public function setConflictSeparator(separator: String) {
        this.conflict_separator = separator;
    }

    public function setView(view: View) {
        this.view = view;
    }

    public function update(local: Dynamic, remote: Dynamic) : Dynamic {
        return view.toDatum(quoteForDiff(view,local) + 
                            separator + 
                            quoteForDiff(view,remote));
    }

    public function conflict(parent: Dynamic, local: Dynamic, 
                             remote: Dynamic) : Dynamic {
        return view.toString(parent) + conflict_separator + 
            view.toString(local) + conflict_separator + 
            view.toString(remote);
    }

    public function marker(label: String) : Dynamic {
        return view.toDatum(label);
    }

    public function links(unit: Unit, row_like: Bool) : Dynamic {
        if (flags.count_like_a_spreadsheet && !row_like) {
            return view.toDatum(unit.toBase26String());
        }
        return view.toDatum(unit.toString());
    }

    static public function quoteForDiff(v: View, d: Dynamic) : String {
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
}
