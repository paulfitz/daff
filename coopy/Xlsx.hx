// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Read and write XLSX format. You don't need to use this to use daff!
 * Feel free to use your own.
 *
 */
@:expose
class Xlsx {
    private var impl : XlsxImpl;

    /**
     *
     * Constructor.
     *
     */
    public function new() : Void {
#if js
        impl = new XlsxJs();
#end
    }

    /**
     *
     * Convert a table to bytes in XLSX format.
     *
     * @param t the table to render
     * @return the table as bytes in XLSX format
     *
     */
    public function renderTable(t: Table) : haxe.io.Bytes {
        if (impl==null) {
            return null;
        }

        var workbook : Workbook = impl.create();
        render(workbook, "Sheet", t);
        return workbook.getBytes();
    }

    /**
     *
     * Convert tables to bytes in XLSX format.
     *
     * @param t the tables to render
     * @return the table as bytes in XLSX format
     *
     */
    public function renderTables(tabs: Tables) : haxe.io.Bytes {
        if (impl==null) {
            return null;
        }

        var workbook : Workbook = impl.create();
        var order : Array<String> = tabs.getOrder();
        if (order.length==0 || tabs.hasInsDel()) {
            render(workbook, "Sheet", tabs.one());
        }
        for (i in 1...order.length) {
            var name : String = order[i];
            var tab : Table = tabs.get(name);
            if (tab.height<=1) continue;
            render(workbook, name, tab);
        }
        return workbook.getBytes();
    }

    private function render(workbook : Workbook, name : String, tab : Table) : Void {
        var worksheet : Worksheet = workbook.addWorksheet(name);

        for (x in 0...tab.width) {
            for (y in 0...tab.height) {
                worksheet.setCellValue(x, y, tab.getCell(x, y));
            }
        }

        worksheet.tryFitColumnWidth();

        var view : View = tab.getCellView();
        var corner : CellInfo = DiffRender.renderCell(tab, view, 0, 0);
        if (corner.category=="") {
            return;
        }

        for (x in 0...tab.width) {
            for (y in 0...tab.height) {
                var color : String = null;

                var cell : CellInfo = DiffRender.renderCell(tab, view, x, y);
                if (cell.category!=null) {
                    color = getColor(cell.category);
                }

                if (color!=null) {
                    worksheet.setCellFillColor(x, y, color);
                }
            }
        }

        worksheet.setAllRowHeight(25);
        worksheet.borderAllCell();
    }

    private function getColor(type) {
        switch (type) {
            case "header":
                return "AAAAFF";
            case "spec":
                return "AAAAAA";
            case "add":
                return "7FFF7F";
            case "conflict":
                return "FF0000";
            case "modify":
                return "7f7fff";
            case "remove":
                return "FF7F7F";
            default:
                return null;
        }
    }

    /**
     *
     * Parse bytes in XLSX format representing a table.
     *
     * @param bytes the table encoded as XLSX-format bytes
     * @param tab the table to store cells in
     * @return true on success
     *
     */
    public function parseTable(bytes: haxe.io.Bytes) : Table {
        if (impl==null) {
            return null;
        }

        var workbook : Workbook = impl.read(bytes);
        var worksheet : Worksheet = workbook.getWorksheet(0);
        return Coopy.tablify(worksheet.getData());
    }
}
