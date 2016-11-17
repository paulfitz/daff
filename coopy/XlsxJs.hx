// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

class XlsxJs implements XlsxImpl {
    public function new() {
    }

    public function create() : Workbook {
        return null;
    }

    public function read(bytes: haxe.io.Bytes) : Workbook {
        return null;
    }
}

class XlsxJsWorkbook implements Workbook {
    public function addWorksheet(name: String) : Worksheet {
        return null;
    }

    public function getWorksheet(index: Int) : Worksheet {
        return null;
    }

    public function getBytes() : haxe.io.Bytes {
        return null;
    }
}

class XlsxJsWorksheet implements Worksheet {
    public function getData() : Dynamic {
        return null;
    }

    public function setCellValue(x: Int, y: Int, value: Dynamic) : Void {
    }
}
