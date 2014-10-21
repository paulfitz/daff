// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

// Hooks to allow customization of how special cells are represented.
interface CellBuilder {
    function needSeparator() : Bool;

    function setSeparator(separator: String) : Void;

    function setConflictSeparator(separator: String) : Void;

    function setView(view: View) : Void;

    function update(local: Dynamic, remote: Dynamic) : Dynamic;

    function conflict(parent: Dynamic, local: Dynamic, remote: Dynamic) : Dynamic;

    function marker(label: String) : Dynamic;

    function links(unit: Unit) : Dynamic;
}
