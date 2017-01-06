// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

interface XlsxImpl {
    public function create() : Workbook;
    public function read(bytes: haxe.io.Bytes) : Workbook;
}
