// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

interface Workbook {
    public function addWorksheet(name: String) : Worksheet;
    public function getWorksheet(index: Int) : Worksheet;
    public function getBytes() : haxe.io.Bytes;
}
