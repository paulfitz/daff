// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class DiffRender {
    private var text_to_insert : Array<String>;
    private var td_open : String;
    private var td_close : String;
    private var open : Bool;
    private var pretty_arrows: Bool;

    public function new() : Void {
        text_to_insert = new Array<String>();
        open = false;
        pretty_arrows = true;
    }

    public function usePrettyArrows(flag: Bool) : Void {
        pretty_arrows = flag;
    }

    private function insert(str: String) : Void {
        text_to_insert.push(str);
    }

    private function beginTable() : Void {
        insert("<table>\n");
    }

    private function beginRow(mode: String) : Void {
        td_open = '<td';
        td_close = '</td>';
        var row_class : String = "";
        if (mode=="header") {
            td_open = "<th";
            td_close = "</th>";
        } else {
            row_class = mode;
        }
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
        insert(txt);
        insert(td_close);
    }

    private function endRow() {
        insert('</tr>\n');
    }

    private function endTable() : Void {
        insert('</table>\n');
    }

    public function html() : String {
        return text_to_insert.join('');
    }

    public function toString() : String {
        return html();
    }


    public static function examineCell(x: Int,
                                       y: Int,
                                       value : String,
                                       vcol : String,
                                       vrow : String,
                                       vcorner : String,
                                       cell : CellInfo) : Void {
        cell.category = "";
        cell.category_given_tr = "";
        cell.separator = "";
        cell.conflicted = false;
        cell.updated = false;
        cell.pvalue = cell.lvalue = cell.rvalue = null;
        cell.value = value;
        if (cell.value==null) cell.value = "";
        cell.pretty_value = cell.value;
        if (vrow==null) vrow = "";
        if (vcol==null) vcol = "";
        var removed_column : Bool = false;
        if (vrow == ":") {
            cell.category = 'move';
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
                if (cell.value.indexOf(part)>=0) {
                    var cat : String = "modify";
                    var div = part;
                    // render with utf8 -> symbol
                    if (part!=full) {
                        if (cell.value.indexOf(full)>=0) {
                            div = full;
                            cat = "conflict";
                            cell.conflicted = true;
                        }
                    }
                    cell.updated = true;
                    cell.separator = div;
                    tokens = cell.pretty_value.split(div);
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
                    cell.pretty_value = pretty_tokens.join(String.fromCharCode(8594));
                    cell.category_given_tr = cell.category = cat;
                    var offset : Int = cell.conflicted?1:0;
                    cell.lvalue = tokens[offset];
                    cell.rvalue = tokens[offset+1];
                    if (cell.conflicted) cell.pvalue = tokens[0];
                }
            }
        }
    }

    public static function markSpaces(sl: String, sr: String) : String {
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

    public static function renderCell(tt: TableText,
                                      x: Int,
                                      y: Int) : CellInfo {
        var cell : CellInfo = new CellInfo();
        var corner : String = tt.getCellText(0,0);
        var off : Int = (corner=="@:@") ? 1 : 0;

        examineCell(x,
                    y,
                    tt.getCellText(x,y),
                    tt.getCellText(x,off),
                    tt.getCellText(off,y),
                    corner,
                    cell);
        return cell;
    }

    public function render(rows: Table) {
        if (rows.width==0||rows.height==0) return;
        var render : DiffRender = this;
        render.beginTable();
        var change_row : Int = -1;
        var tt : TableText = new TableText(rows);
        var cell : CellInfo = new CellInfo();
        var corner : String = tt.getCellText(0,0);
        var off : Int = (corner=="@:@") ? 1 : 0;
        if (off>0) {
            if (rows.width<=1||rows.height<=1) return;
        }
        for (row in 0...rows.height) {

            var open : Bool = false;

            var txt : String = tt.getCellText(off,row);
            if (txt==null) txt = "";
            examineCell(0,row,txt,"",txt,corner,cell);
            var row_mode : String = cell.category;
            if (row_mode == "spec") {
                change_row = row;
            }

            render.beginRow(row_mode);

            for (c in 0...rows.width) {
                examineCell(c,
                            row,
                            tt.getCellText(c,row),
                            (change_row>=0)?tt.getCellText(c,change_row):"",
                            txt,
                            corner,
                            cell);
                render.insertCell(pretty_arrows?cell.pretty_value:cell.value,
                                  cell.category_given_tr);
            }
            render.endRow();
        }
        render.endTable();
    }

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

.highlighter th, .highlighter .header { 
  background-color: #aaf;
  font-weight: bold;
  padding-bottom: 4px;
  padding-top: 5px;
  text-align:left;
}

.highlighter tr:first-child td {
  border-top: 1px solid #2D4068;
}

.highlighter td:first-child { 
  border-left: 1px solid #2D4068;
}

.highlighter td {
  empty-cells: show;
}
";
    }

    public function completeHtml() : Void {
        text_to_insert.insert(0,"<html>
<meta charset='utf-8'>
<head>
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

