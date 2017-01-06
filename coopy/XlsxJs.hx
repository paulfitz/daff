// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

class XlsxJs implements XlsxImpl {
    public function new() {
        untyped __js__("if (!require('fibers').current) throw('run inside Fiber plz')");
    }

    public function create() : Workbook {
        var workbook = new exceljs.Workbook();
        return new XlsxJsWorkbook(workbook);
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
        var worksheet = workbook.addWorksheet(name);
        return new XlsxJsWorksheet(worksheet);
    }

    public function getWorksheet(index: Int) : Worksheet {
        var adjustedIndex = index + 1;
        var worksheet = workbook.getWorksheet(adjustedIndex);
        return new XlsxJsWorksheet(worksheet);
    }

    public function getBytes() : haxe.io.Bytes {
        var stream = new WritableStreamBuffer();
        untyped __js__("require('fibers/future').fromPromise(this.workbook.xlsx.write(stream)).wait()");
        return stream.getContents();
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
        worksheet.getCell(y + 1, x + 1).value = value;
    }

    public function setCellFillColor(x: Int, y: Int, color: String) : Void {
        worksheet.getCell(y + 1, x + 1).fill = {
            type: "pattern",
            pattern: "solid",
            fgColor: {
                argb: "FF" + color
            }
        };
    }

    public function tryFitColumnWidth() : Bool {
        for (i in 0...worksheet.columns.length) {
            var column = worksheet.columns[i];
            var maxLength = 5;
            worksheet.eachRow(function (row, rowNumer) {
                maxLength = Std.int(Math.max(maxLength, row.getCell(i + 1).text.length));
            });
            var widthPerLength = 1.5;
            column.width = Std.int(maxLength * widthPerLength);
        }
        return false;
    }

    public function setAllRowHeight(height: Int) : Void {
        worksheet.eachRow(function (row, rowNumber) {
            row.height = height;
        });
    }

    public function borderAllCell() : Void {
        var border = {
            style: "thin",
            color: {
                argb: "#FF000000"
            }
        };
        var borders = {
            top: border,
            left: border,
            bottom: border,
            right: border
        };

        worksheet.eachRow({ includeEmpty: true }, function (row, rowNumber) {
            row.eachCell({ includeEmpty: true }, function (cell, colNumber) {
                cell.border = borders;
            });
        });
    }
}

@:jsRequire("stream-buffers", "ReadableStreamBuffer")
extern class ReadableStreamBuffer {
    public function new();

    public function put(bytes: haxe.io.Bytes) : Void;
    public function stop() : Void;
}

@:jsRequire("stream-buffers", "WritableStreamBuffer")
extern class WritableStreamBuffer {
    public function new();

    public function getContents() : haxe.io.Bytes;
}
