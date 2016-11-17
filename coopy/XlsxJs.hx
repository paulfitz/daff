// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

class XlsxJs implements XlsxImpl {
    public function new() {
        untyped __js__("if (!require('fibers').current) throw('run inside Fiber plz')");
    }

    public function create() : Workbook {
        return null;
    }

    public function read(bytes: haxe.io.Bytes) : Workbook {
        var workbook = new exceljs.Workbook();
        var stream = new ReadableStreamBuffer();
        stream.put(bytes);
        stream.stop();
        untyped __js__("require('fibers/future').fromPromise(workbook.xlsx.read(stream)).wait()");
        return new XlsxJsWorkbook(workbook);
    }
}

class XlsxJsWorkbook implements Workbook {
    private var workbook : exceljs.Workbook;

    public function new(workbook: exceljs.Workbook) {
        this.workbook = workbook;
    }

    public function addWorksheet(name: String) : Worksheet {
        return null;
    }

    public function getWorksheet(index: Int) : Worksheet {
        var adjustedIndex = index + 1;
        var worksheet = workbook.getWorksheet(adjustedIndex);
        return new XlsxJsWorksheet(worksheet);
    }

    public function getBytes() : haxe.io.Bytes {
        return null;
    }
}

class XlsxJsWorksheet implements Worksheet {
    private var worksheet : exceljs.Sheet;

    public function new(worksheet: exceljs.Sheet) {
        this.worksheet = worksheet;
    }

    public function getData() : Dynamic {
        var rows = [];
        worksheet.eachRow({ includeEmpty: true }, function (row, rowNumber) {
            rows[rowNumber - 1] = row.values.slice(1);
        });
        return rows;
    }

    public function setCellValue(x: Int, y: Int, value: Dynamic) : Void {
    }
}

@:jsRequire("stream-buffers", "ReadableStreamBuffer")
extern class ReadableStreamBuffer {
    public function new();

    public function put(bytes: haxe.io.Bytes) : Void;
    public function stop() : Void;
}
