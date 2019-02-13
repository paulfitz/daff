// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Convert a tabular diff into html form.  Typically called as `render(table).html()`.
 *
 */
@:expose
class DiffRender {
    private var text_to_insert : Array<String>;
    private var td_open : String;
    private var td_close : String;
    private var open : Bool;
    private var pretty_arrows: Bool;
    private var quote_html: Bool;
    private var section : String;

    public function new() : Void {
        text_to_insert = new Array<String>();
        open = false;
        pretty_arrows = true;
        quote_html = true;
    }

    /**
     *
     * Call this if you want arrow separators `->` to be converted to prettier
     * glyphs.
     *
     */
    public function usePrettyArrows(flag: Bool) : Void {
        pretty_arrows = flag;
    }

    public function quoteHtml(flag: Bool) : Void {
        quote_html = flag;
    }

    private function insert(str: String) : Void {
        text_to_insert.push(str);
    }

    private function beginTable() : Void {
        insert("<table>\n");
        section = null;
    }

    private function setSection(str: String) : Void {
        if (str==section) return;
        if (section!=null) {
            insert("</t");
            insert(section);
            insert(">\n");
        }
        section = str;
        if (section!=null) {
            insert("<t");
            insert(section);
            insert(">\n");
        }
    }

    private function beginRow(mode: String) : Void {
        td_open = '<td';
        td_close = '</td>';
        var row_class : String = "";
        if (mode=="header") {
            td_open = "<th";
            td_close = "</th>";
        }
        row_class = mode;
        var tr : String = "<tr>";
        if (row_class!="") {
            tr = "<tr class=\"" + row_class + "\">";
        }
        insert(tr);
    }

    private function insertCell(txt : String, mode : String) : Void {
        var cell_decorate : String = "";
        if (mode!="") {
            cell_decorate = " class=\"" + mode + "\"";
        }
        insert(td_open+cell_decorate+">");
        if (txt!=null) {
            insert(txt);
        } else {
            insert("null");
        }
        insert(td_close);
    }

    private function endRow() {
        insert('</tr>\n');
    }


    private function endTable() : Void {
        setSection(null);
        insert('</table>\n');
    }

    /**
     *
     * @return the generated html, make sure to call `render(table)` first
     * or it will be empty
     *
     */
    public function html() : String {
        return text_to_insert.join('');
    }

    /**
     *
     * @return the generated html
     *
     */
    public function toString() : String {
        return html();
    }


    /**
     *
     * Combine information about a single cell given row and column
     * header information.  Usually `renderCell` will be much easier
     * to use, this method is deprecated.
     *
     */
    public static function examineCell(x: Int,
                                       y: Int,
                                       view : View,
                                       raw : Dynamic,
                                       vcol : String,
                                       vrow : String,
                                       vcorner : String,
                                       cell : CellInfo,
                                       offset : Int = 0) : Void {
        var nested = view.isHash(raw);
        cell.category = "";
        cell.category_given_tr = "";
        cell.separator = "";
        cell.pretty_separator = "";
        cell.conflicted = false;
        cell.updated = false;
        cell.meta = cell.pvalue = cell.lvalue = cell.rvalue = null;
        cell.value = raw;
        cell.pretty_value = cell.value;
        if (vrow==null) vrow = "";
        if (vcol==null) vcol = "";
        if (vrow.length>=3 && vrow.charAt(0) == "@" && vrow.charAt(1) != "@") {
            var idx = vrow.indexOf("@",1);
            if (idx>=0) {
                cell.meta = vrow.substr(1,idx-1);
                vrow = vrow.substr(idx+1,vrow.length);
                cell.category = 'meta';
            }
        }
        var removed_column : Bool = false;
        if (vrow == ":") {
            cell.category = 'move';
        }
        if (vrow == "" && offset == 1 && y == 0) {
            cell.category = 'index';
        }
        if (vcol.indexOf("+++")>=0) {
            cell.category_given_tr = cell.category = 'add';
        } else if (vcol.indexOf("---")>=0) {
            cell.category_given_tr = cell.category = 'remove';
            removed_column = true;
        }
        if (vrow == "!") {
            cell.category = 'spec';
        } else if (vrow == "@@") {
            cell.category = 'header';
        } else if (vrow == "...") {
            cell.category = 'gap';
        } else if (vrow == "+++") {
            if (!removed_column) {
                cell.category = 'add';
            }
        } else if (vrow == "---") {
            cell.category = "remove";
        } else if (vrow.indexOf("->")>=0) {
            if (!removed_column) {
                var tokens : Array<String> = vrow.split("!");
                var full : String = vrow;
                var part : String = tokens[1];
                if (part==null) part = full;
                var str = view.toString(cell.value);
                if (str==null) str = "";
                if (nested || str.indexOf(part)>=0) {
                    var cat : String = "modify";
                    var div = part;
                    // render with utf8 -> symbol
                    if (part!=full) {
                        if (nested) {
                            cell.conflicted = view.hashExists(raw,"theirs");
                        } else {
                            cell.conflicted = str.indexOf(full)>=0;
                        }
                        if (cell.conflicted) {
                            div = full;
                            cat = "conflict";
                        }
                    }
                    cell.updated = true;
                    cell.separator = div;
                    cell.pretty_separator = div;
                    if (nested) {
                        if (cell.conflicted) {
                            tokens = [view.hashGet(raw,"before"),
                                      view.hashGet(raw,"ours"),
                                      view.hashGet(raw,"theirs")];
                        } else {
                            tokens = [view.hashGet(raw,"before"),
                                      view.hashGet(raw,"after")];
                        }
                    } else {
                        cell.pretty_value = view.toString(cell.pretty_value);
                        if (cell.pretty_value==null) cell.pretty_value = "";
                        if (cell.pretty_value==div) {
                            tokens = ["",""];
                        } else {
                            tokens = cell.pretty_value.split(div);
                        }
                    }
                    var pretty_tokens : Array<String> = tokens;
                    if (tokens.length>=2) {
                        pretty_tokens[0] = markSpaces(tokens[0],tokens[1]);
                        pretty_tokens[1] = markSpaces(tokens[1],tokens[0]);
                    }
                    if (tokens.length>=3) {
                        var ref : String = pretty_tokens[0];
                        pretty_tokens[0] = markSpaces(ref,tokens[2]);
                        pretty_tokens[2] = markSpaces(tokens[2],ref);
                    }
                    cell.pretty_separator = String.fromCharCode(8594);
                    cell.pretty_value = pretty_tokens.join(cell.pretty_separator);
                    cell.category_given_tr = cell.category = cat;
                    var offset : Int = cell.conflicted?1:0;
                    cell.lvalue = tokens[offset];
                    cell.rvalue = tokens[offset+1];
                    if (cell.conflicted) cell.pvalue = tokens[0];
                }
            }
        }
        if (x==0 && offset>0) {
            cell.category_given_tr = cell.category = 'index';
        }
    }

    private static function markSpaces(sl: String, sr: String) : String {
        if (sl==sr) return sl;
        if (sl==null || sr==null) return sl;
        var slc : String = StringTools.replace(sl," ","");
        var src : String = StringTools.replace(sr," ","");
        if (slc!=src) return sl;
        var slo : String = new String("");
        var il : Int = 0;
        var ir : Int = 0;
        while (il<sl.length) {
            var cl : String = sl.charAt(il);
            var cr : String = "";
            if (ir<sr.length) {
                cr = sr.charAt(ir);
            }
            if (cl==cr) {
                slo += cl;
                il++;
                ir++;
            } else if (cr==" ") {
                ir++;
            } else {
                slo += String.fromCharCode(9251);
                il++;
            }
        }
        return slo;
    }

    /**
     *
     * Extract information about a single cell.
     * Useful if you are doing custom rendering.
     *
     * @param tab the table
     * @param view a viewer for cells of the table
     * @param x cell column
     * @param y cell row
     * @return details of what is in the cell
     *
     */
    public static function renderCell(tab: Table,
                                      view: View,
                                      x: Int,
                                      y: Int) : CellInfo {
        var cell : CellInfo = new CellInfo();
        var corner : String = view.toString(tab.getCell(0,0));
        var off : Int = (corner=="@:@") ? 1 : 0;

        examineCell(x,
                    y,
                    view,
                    tab.getCell(x,y),
                    view.toString(tab.getCell(x,off)),
                    view.toString(tab.getCell(off,y)),
                    corner,
                    cell,
                    off);
        return cell;
    }

    /**
     *
     * Render a table as html - call `html()` or similar to get the result.
     *
     * @param tab the table to render
     * @return self, so you can call render(table).html()
     *
     */
    public function render(tab: Table) : DiffRender {
        tab = Coopy.tablify(tab); // accept native tables
        if (tab.width==0||tab.height==0) return this;
        var render : DiffRender = this;
        render.beginTable();
        var change_row : Int = -1;
        var cell : CellInfo = new CellInfo();
        var view = tab.getCellView();
        var corner : String = view.toString(tab.getCell(0,0));
        var off : Int = (corner=="@:@") ? 1 : 0;
        if (off>0) {
            if (tab.width<=1||tab.height<=1) return this;
        }
        for (row in 0...tab.height) {

            var open : Bool = false;

            var txt : String = view.toString(tab.getCell(off,row));
            if (txt==null) txt = "";
            examineCell(off,row,view,txt,"",txt,corner,cell,off);
            var row_mode : String = cell.category;
            if (row_mode == "spec") {
                change_row = row;
            }
            if (row_mode == "header" || row_mode == "spec" || row_mode=="index" || row_mode=="meta") {
                setSection("head");
            } else {
                setSection("body");
            }

            render.beginRow(row_mode);

            for (c in 0...tab.width) {
                examineCell(c,
                            row,
                            view,
                            tab.getCell(c,row),
                            (change_row>=0)?view.toString(tab.getCell(c,change_row)):"",
                            txt,
                            corner,
                            cell,
                            off);
                var val = pretty_arrows?cell.pretty_value:cell.value;
                if (quote_html) {
                    val = StringTools.htmlEscape(view.toString(val));
                }
                render.insertCell(val, cell.category_given_tr);
            }
            render.endRow();
        }
        render.endTable();
        return this;
    }

    public function renderTables(tabs: Tables) : DiffRender {
        var order : Array<String> = tabs.getOrder();
        var start = 0;
        if (order.length<=1 || tabs.hasInsDel()) {
            render(tabs.one());
            start = 1;
        }
        for (i in start...order.length) {
            var name = order[i];
            var tab : Table = tabs.get(name);
            if (tab.height<=1) continue;
            insert("<h3>");
            insert(name);
            insert("</h3>\n");
            render(tab);
        }
        return this;
    }

    /**
     *
     * @return sample css for the generated html
     *
     */
    public function sampleCss() : String {
        return ".highlighter .add { 
  background-color: #7fff7f;
}

.highlighter .remove { 
  background-color: #ff7f7f;
}

.highlighter td.modify { 
  background-color: #7f7fff;
}

.highlighter td.conflict { 
  background-color: #f00;
}

.highlighter .spec { 
  background-color: #aaa;
}

.highlighter .move { 
  background-color: #ffa;
}

.highlighter .null { 
  color: #888;
}

.highlighter table { 
  border-collapse:collapse;
}

.highlighter td, .highlighter th {
  border: 1px solid #2D4068;
  padding: 3px 7px 2px;
}

.highlighter th, .highlighter .header, .highlighter .meta {
  background-color: #aaf;
  font-weight: bold;
  padding-bottom: 4px;
  padding-top: 5px;
  text-align:left;
}

.highlighter tr.header th {
  border-bottom: 2px solid black;
}

.highlighter tr.index td, .highlighter .index, .highlighter tr.header th.index {
  background-color: white;
  border: none;
}

.highlighter .gap {
  color: #888;
}

.highlighter td {
  empty-cells: show;
  white-space: pre-wrap;
}
";
    }

    /**
     *
     * Call this after rendering the table to add a header/footer
     * and style sheet for a complete test page.
     *
     */
    public function completeHtml() : Void {
        text_to_insert.insert(0,"<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8'>
<style TYPE='text/css'>
");
        text_to_insert.insert(1,sampleCss());
        text_to_insert.insert(2,"</style>
</head>
<body>
<div class='highlighter'>
");
        text_to_insert.push("</div>
</body>
</html>
");
    }
}

