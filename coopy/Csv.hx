// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class Csv {
    private var cursor: Int;
    private var row_ended: Bool;
    private var has_structure : Bool;

    public function new() : Void {
        cursor = 0;
        row_ended = false;
    }

    public function renderTable(t: Table) : String {
        var result: String = "";
        var w : Int = t.width;
        var h : Int = t.height;
        var txt : String = "";
        var v : View = t.getCellView();
        for (y in 0...h) {
            for (x in 0...w) {
                if (x>0) {
                    txt += ",";
                }
                txt += renderCell(v,t.getCell(x,y));
            }
            txt += "\r\n";
        }
        return txt;
    }

    public function renderCell(v: View, d: Datum) : String {
        if (d==null) {
            return "NULL";
        }
        if (v.equals(d,null)) {
            return "NULL";
        }
        var str: String = v.toString(d);
        var delim: String = ",";
        var need_quote : Bool = false;
        for (i in 0...str.length) {
            var ch : String = str.charAt(i);
            if (ch=='"'||ch=='\''||ch==delim||ch=='\r'||ch=='\n'||ch=='\t'||ch==' ') {
                need_quote = true;
                break;
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
        if (need_quote) { result += '"'; }
        return result;
    }

    public function parseTable(txt: String) : Array<Array<String>> {
        cursor = 0;
        row_ended = false;
        has_structure = true;
        var result: Array<Array<String>> = new Array<Array<String>>();
        var row: Array<String> = new Array<String>();
        while (cursor<txt.length) {
            var cell : String = parseCell(txt);
            row.push(cell);
            if (row_ended) {
                result.push(row);
                row = new Array<String>();
            }
            cursor++;
        }
        return result;
    }

    public function parseCell(txt: String) : String {
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
                    if (ch==",".code) {
                        break;
                    }
                    if (ch=="\r".code || ch=="\n".code) {
                        var ch2: Null<Int> = txt.charCodeAt(i+1);
                        if (ch2!=null) {
                            if (ch2!=ch) {
                                if (ch2=="\r".code || ch2=="\n".code) {
                                    last_processed++;
                                }
                            }
                        }
                        row_ended = true;
                        break;
                    }
                    if (ch=="\"".code || ch=="\'".code) {
                        quoting = true;
                        quote = ch;
                        if (i!=start) {
                            result += String.fromCharCode(ch);
                        }
                        continue;
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

    public function parseSingleCell(txt: String) : String {
        cursor = 0;
        row_ended = false;
        has_structure = false;
        return parseCell(txt);
    }

}
