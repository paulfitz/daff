// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class DiffRender {
    private var text_to_insert : Array<String>;
    private var td_open : String;
    private var td_close : String;
    private var row_color : String;
    private var open : Bool;

    public function new() : Void {
        text_to_insert = new Array<String>();
        open = false;
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
        row_color = "";
        open = false;
        switch(mode) {
        case "@@":
            td_open = "<th";
            td_close = "</th>";
        case "!":
            row_color = "spec";
        case "+++":
            row_color = "add";
        case "---":
            row_color = "remove";
        default:
            this.open = true;
        }
        var tr : String = "<tr>";
        var row_decorate : String = "";
        if (row_color!="") {
            row_decorate = " class=\"" + row_color + "\"";
            tr = "<tr" + row_decorate + ">";
        }
        insert(tr);
    }


    private function insertCell(txt : String,mode : String,separator : String) : Void {
        var cell_decorate : String = "";
        switch (mode) {
        case "+++":
            cell_decorate += " class=\"add\"";
        case "---":
            cell_decorate += " class=\"remove\"";
        case "->":
            cell_decorate += " class=\"modify\"";
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


    public function render(rows: Table) {
        var render : DiffRender = this;
        render.beginTable();
        var change_row : Int = -1;
        var v : View = rows.getCellView();
        for (row in 0...rows.height) {
            //var r = rows[row];
            var row_mode : String = "";
            var txt : String = "";
            var open : Bool = false;
            if (rows.width>0) {
                txt = v.toString(rows.getCell(0,row));
                if (txt=="@"||txt=="@@") {
                    row_mode = "@@";
                } else if (txt=="!"||txt=="+++"||txt=="---"||txt=="...") {
                    row_mode = txt;
                    if (txt=="!") { change_row = row; }
                } else if (txt.indexOf("->")>=0) {
                    row_mode = "->";
                } else {
                    open = true;
                }
            }
            var cmd : String = txt;
            render.beginRow(row_mode);
            for (c in 0...rows.width) {
                txt = v.toString(rows.getCell(c,row));
                if (txt=="NULL") txt = "";
                if (txt=="null") txt = "";
                var cell_mode : String = "";
                var separator : String = "";
                if (open && change_row>=0) {
                    var change = v.toString(rows.getCell(c,change_row));
                    if (change=="+++"||change=="---") {
                        cell_mode = change;
                    }
                }
                
                if (cmd.indexOf("->")>=0) {
                    if (txt.indexOf(cmd)>=0) {
                        cell_mode = "->";
                        separator = cmd;
                    }
                }
                render.insertCell(txt,cell_mode,separator);
            }
            render.endRow();
        }
        render.endTable();
    }
}

