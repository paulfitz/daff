// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Read and write CSV format. You don't need to use this to use daff!
 * Feel free to use your own.
 *
 */
@:expose
class Csv {
    private var cursor: Int;
    private var row_ended: Bool;
    private var has_structure : Bool;
    private var delim : String;
    private var discovered_eol : String;
    private var preferred_eol : String;

    /**
     *
     * Constructor.
     *
     * @param delim cell delimiter to use, defaults to a comma
     *
     */
    public function new(?delim : String = ",", ?eol : String = null) : Void {
        cursor = 0;
        row_ended = false;
        this.delim = (delim==null)?",":delim;
        this.discovered_eol = null;
        this.preferred_eol = eol;
    }

    /**
     *
     * Convert a table to a string in CSV format.
     *
     * @param t the table to render
     * @return the table as a string in CSV format
     *
     */
    public function renderTable(t: Table) : String {
        var eol = preferred_eol;
        if (eol == null) {
            eol = "\r\n"; // The "standard" says line endings should be this
        }
        var result: String = "";
        var v : View = t.getCellView();
        var stream = new TableStream(t);
        var w = stream.width();
        var txts = new Array<String>();
        while (stream.fetch()) {
            for (x in 0...w) {
                if (x>0) {
                    txts.push(delim);
                }
                txts.push(renderCell(v,stream.getCell(x)));
            }
            txts.push(eol);
        }
        return txts.join("");
    }

    /**
     *
     * Render a single cell in CSV format.
     *
     * @param v a helper for interpreting the cell content
     * @param d the cell content
     * @param force_quote set if cell should always be quoted
     * @return the cell in text format, quoted in a CSV-y way
     *
     */
    public function renderCell(v: View, d: Dynamic, force_quote: Bool = false) : String {
        if (d==null) {
            return "NULL"; // I don't like this, why is it here?
        }
        var str: String = v.toString(d);
        var need_quote : Bool = force_quote;
        if (!need_quote) {
            if (str.length > 0) {
                if (str.charAt(0)==' '||str.charAt(str.length-1)==' ') {
                    need_quote = true;
                }
            }
        }
        if (!need_quote) {
            for (i in 0...str.length) {
                var ch : String = str.charAt(i);
                if (ch=='"'||ch=='\r'||ch=='\n'||ch=='\t') {
                    need_quote = true;
                    break;
                }
                if (ch==delim.charAt(0)) {
                    if (delim.length==1) {
                        need_quote = true;
                        break;
                    }
                    // handle multi-char delims, like poop emoji in
                    // javascript
                    if (i+delim.length<=str.length) {
                        var match = true;
                        for (j in 1...delim.length) {
                            if (str.charAt(i+j)!=delim.charAt(j)) {
                                match = false;
                                break;
                            }
                        }
                        if (match) {
                            need_quote = true;
                            break;
                        }
                    }
                }
            }
        }
        
        var result : String = "";
        if (need_quote) { result += '"'; }
        var line_buf : String = "";
        for (i in 0...str.length) {
            var ch : String = str.charAt(i);
            if (ch=='"') {
                result += '"';
            }
            if (ch!='\r'&&ch!='\n') {
                if (line_buf.length>0) {
                    result += line_buf;
                    line_buf = "";
                }
                result += ch;
            } else {
                line_buf+=ch;
            }
        }
        if (line_buf.length>0) {
            result += line_buf;
        }
        if (need_quote) { result += '"'; }
        return result;
    }

    /**
     *
     * Parse a string in CSV format representing a table.
     *
     * @param txt the table encoded as a CSV-format string
     * @param tab the table to store cells in
     * @return true on success
     *
     */
    public function parseTable(txt: String, tab: Table) : Bool {
        if (!tab.isResizable()) return false;
        cursor = 0;
        row_ended = false;
        has_structure = true;
        tab.resize(0,0);
        var w: Int = 0;
        var h: Int = 0;
        var at: Int = 0;
        var yat: Int = 0;
        while (cursor<txt.length) {
            var cell : String = parseCellPart(txt);
            if (yat>=h) {
                h = yat+1;
                tab.resize(w,h);
            }
            if (at>=w) {
                if (yat>0) {
                    if (cell != "" && cell != null) {
                        var context : String = "";
                        for (i in 0...w) {
                            if (i>0) context += ",";
                            context += tab.getCell(i,yat);
                        }
                        trace("Ignored overflowing row " + yat + " with cell '" + cell + "' after: " + context);
                    }
                } else {
                    w = at+1;
                    tab.resize(w,h);
                }
            }
            tab.setCell(at,h-1,cell);
            at++;
            if (row_ended) {
                at = 0;
                yat++;
            }
            cursor++;
        }
        return true;
    }


    /**
     *
     * Create a table from a string in CSV format.
     *
     * @param txt the table encoded as a CSV-format string
     * @return the decoded table
     *
     */
    public function makeTable(txt: String) : Table {
        var tab = new SimpleTable(0,0);
        parseTable(txt,tab);
        return tab;
    }


    private function parseCellPart(txt: String) : String {
        if (txt==null) return null;
        row_ended = false;
        var first_non_underscore : Int = txt.length;
        var last_processed : Int = 0;
        var quoting : Bool = false;
        var quote : Int = 0;
        var result : String = "";
        var start: Int = cursor;
        for (i in cursor...(txt.length)) {
            var ch: Int = txt.charCodeAt(i);
            last_processed = i;
            if (ch!="_".code && i<first_non_underscore) {
                first_non_underscore = i;
            }
            if (has_structure) {
                if (!quoting) {
                    if (ch==delim.charCodeAt(0)) {
                        if (delim.length==1) {
                            break;
                        }
                        if (i+delim.length<=txt.length) {
                            var match = true;
                            for (j in 1...delim.length) {
                                if (txt.charAt(i+j)!=delim.charAt(j)) {
                                    match = false;
                                    break;
                                }
                            }
                            if (match) {
                                last_processed+=delim.length-1;
                                break;
                            }
                        }
                    }
                    if (ch=="\r".code || ch=="\n".code) {
                        var ch2: Null<Int> = txt.charCodeAt(i+1);
                        if (ch2!=null) {
                            if (ch2!=ch) {
                                if (ch2=="\r".code || ch2=="\n".code) {
                                    if (discovered_eol==null) {
                                        discovered_eol = String.fromCharCode(ch) +
                                            String.fromCharCode(ch2);
                                    }
                                    last_processed++;
                                }
                            }
                        }
                        if (discovered_eol==null) {
                            discovered_eol = String.fromCharCode(ch);
                        }
                        row_ended = true;
                        break;
                    }
                    if (ch=="\"".code) {
                        if (i==cursor) {
                            quoting = true;
                            quote = ch;
                            if (i!=start) {
                                result += String.fromCharCode(ch);
                            }
                            continue;
                        } else if (ch==quote) {
                            quoting = true;
                        }
                    }
                    result += String.fromCharCode(ch);
                    continue;
                }
                if (ch==quote) {
                    quoting = false;
                    continue;
                }
            }
            result += String.fromCharCode(ch);
        }
        cursor = last_processed;
        if (quote==0) {
            if (result=="NULL") {
                return null;
            }
            if (first_non_underscore>start) {
                var del : Int = first_non_underscore-start;
                if (result.substr(del)=="NULL") {
                    return result.substr(1);
                }
            }
        }
        return result;
    }

    /**
     *
     * Parse a string in CSV format representing a cell.
     *
     * @param txt the cell encoded as a CSV-format string
     * @return the decoded content of the cell
     *
     */
    public function parseCell(txt: String) : String {
        cursor = 0;
        row_ended = false;
        has_structure = false;
        return parseCellPart(txt);
    }

    /**
     *
     * Return the EOL sequence discovered the last time
     * a CSV file/string was parsed.
     *
     * @return one of "\n", "\r", "\n\r", "\r\n", null
     *
     */
    public function getDiscoveredEol() : String {
        return discovered_eol;
    }

    /**
     *
     * Set the EOL sequence to use at end of rows.
     * a CSV file/string was parsed.
     *
     * @param eol "\n" or "\r\n" - if it is something else
     * I don't want to know.
     *
     */
    public function setPreferredEol(eol: String) : Void {
        preferred_eol = eol;
    }
}
