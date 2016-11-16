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
    /**
     *
     * Constructor.
     *
     */
    public function new() : Void {
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
        return null;
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
        return null;
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
        return null;
    }
}
