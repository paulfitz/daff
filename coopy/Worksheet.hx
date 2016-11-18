// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

interface Worksheet {
    public function getData() : Dynamic;
    public function setCellValue(x: Int, y: Int, value: Dynamic) : Void;
    public function setCellFillColor(x: Int, y: Int, color: String) : Void;
    public function tryFitColumnWidth() : Bool;
    public function setAllRowHeight(height: Int) : Void;
    public function borderAllCell() : Void;
}
