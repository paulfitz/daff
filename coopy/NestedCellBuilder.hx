// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:noDoc
class NestedCellBuilder implements CellBuilder {
    private var view : View;

    public function new() {
    }

    public function needSeparator() {
        return false;
    }

    public function setSeparator(separator: String) {
    }

    public function setConflictSeparator(separator: String) {
    }

    public function setView(view: View) {
        this.view = view;
    }

    public function update(local: Dynamic, remote: Dynamic) : Dynamic {
        var h = view.makeHash();
        view.hashSet(h,"before",local);
        view.hashSet(h,"after",remote);
        return h;
    }

    public function conflict(parent: Dynamic, local: Dynamic, 
                             remote: Dynamic) : Dynamic {
        var h = view.makeHash();
        view.hashSet(h,"before",parent);
        view.hashSet(h,"ours",local);
        view.hashSet(h,"theirs",remote);
        return h;
    }

    public function marker(label: String) : Dynamic {
        return view.toDatum(label);
    }

    private function negToNull(x: Int) : Null<Int> {
        if (x<0) return null;
        return x;
    }

    public function links(unit: Unit, row_like: Bool) : Dynamic {
        var h = view.makeHash();
        if (unit.p>=-1) {
            view.hashSet(h,"before",negToNull(unit.p));
            view.hashSet(h,"ours",negToNull(unit.l));
            view.hashSet(h,"theirs",negToNull(unit.r));
            return h;
        }
        view.hashSet(h,"before",negToNull(unit.l));
        view.hashSet(h,"after",negToNull(unit.r));
        return h;
    }
}
