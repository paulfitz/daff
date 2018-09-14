// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class BasicTest extends haxe.unit.TestCase {
    var data1 : Array<Array<Dynamic>>;
    var data2 : Array<Array<Dynamic>>;
    var data3 : Array<Array<Dynamic>>;
    var data4 : Array<Array<Dynamic>>;
    var data5 : Array<Array<Dynamic>>;
    var data6 : Array<Array<Dynamic>>;
    var data7 : Array<Array<Dynamic>>;

    override public function setup() {
        data1 = [['Country','Capital'],
                 ['Ireland','Dublin'],
                 ['France','Paris'],
                 ['Spain','Barcelona']];
        data2 = [['Country','Code','Capital'],
                 ['Ireland','ie','Dublin'],
                 ['France','fr','Paris'],
                 ['Spain','es','Madrid'],
                 ['Germany','de','Berlin']];
        data3 = [['Country','Capital','Time'],
                 ['Ireland','Baile Atha Cliath',0],
                 ['France','Paris',1],
                 ['Spain','Barcelona',1]];
        data4 = [['Country','Code','Capital','Time'],
                 ['Ireland','ie','Baile Atha Cliath',0],
                 ['France','fr','Paris',1],
                 ['Spain','es','Madrid',1],
                 ['Germany','de','Berlin',null]];
        data5 = [['Country','Code','Capital'],
                 ['Ireland','xie','Dublinx'],
                 ['France','xfr','Parisx'],
                 ['Spain','es','Madridx'],
                 ['Germany','de','Berlinx']];
        data6 = [['Country','Time','Code','Capital','Golfers'],
                 ['Ireland',0,'ie','Baile Atha Cliath',1000],
                 ['France',1,'fr','Paris',10000],
                 ['Spain',1,'es','Madrid',2000],
                 ['Germany',null,'de','Berlin',2]];
        data7 = [['Country','Capital'],
                 ['Ireland','Dublin'],
                 ['France','<i>Paris</i>...'],
                 ['Spain','Barcelona']];
    }

    public function testBasic(){
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var alignment = coopy.Coopy.compareTables(table1,table2).align();
        var data_diff = [];
        var table_diff = Native.table(data_diff);
        var flags = new coopy.CompareFlags();
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        assertEquals(""+table_diff.getCell(0,4),"->");
        assertTrue(highlighter.hasDifference());
        var summary = highlighter.getSummary();
        assertEquals(summary.row_deletes,0);
        assertEquals(summary.row_inserts,1);
        assertEquals(summary.row_updates,1);
        assertEquals(summary.col_deletes,0);
        assertEquals(summary.col_inserts,1);
        assertEquals(summary.col_updates,1);
        assertEquals(summary.row_count_initial_with_header,4);
        assertEquals(summary.row_count_final_with_header,5);
        assertEquals(summary.row_count_initial,3);
        assertEquals(summary.row_count_final,4);
        assertEquals(summary.col_count_initial,2);
        assertEquals(summary.col_count_final,3);
    }

    public function testBasicReversed(){
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var alignment = coopy.Coopy.compareTables(table2,table1).align();
        var data_diff = [];
        var table_diff = Native.table(data_diff);
        var flags = new coopy.CompareFlags();
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        var summary = highlighter.getSummary();
        assertEquals(summary.row_deletes,1);
        assertEquals(summary.row_inserts,0);
        assertEquals(summary.row_updates,1);
        assertEquals(summary.col_deletes,1);
        assertEquals(summary.col_inserts,0);
        assertEquals(summary.col_updates,1);
    }

    public function testBasicModern(){
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var data_diff = coopy.Coopy.diff(table1,table2);
        assertEquals(""+data_diff.getCell(0,4),"->");
    }

    public function testNamedID(){
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var flags = new coopy.CompareFlags();
        flags.addPrimaryKey("Capital");
        var alignment = coopy.Coopy.compareTables(table1,table2,flags).align();
        var data_diff = [];
        var table_diff = Native.table(data_diff);
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        assertEquals(""+table_diff.getCell(3,6),"Barcelona");
    }

    public function testCSV() {
        var txt = "name,age\nPaul,\"7,9\"\n\"Sam\nSpace\",\"\"\"\"\n";
        var tab = Native.table([]);
        var csv = new coopy.Csv();
        csv.parseTable(txt,tab);
        assertEquals(3,tab.height);
        assertEquals(2,tab.width);
        assertEquals("Paul",tab.getCell(0,1));
        assertEquals("\"",tab.getCell(1,2));
    }

    public function testCSVLongDelim() {
        var txt = "nameBORKage\n\"BORK\"BORKBOR\n";
        var tab = Native.table([]);
        var csv = new coopy.Csv("BORK");
        csv.parseTable(txt,tab);
        assertEquals(2,tab.height);
        assertEquals(2,tab.width);
        assertEquals("name",tab.getCell(0,0));
        assertEquals("age",tab.getCell(1,0));
        assertEquals("BORK",tab.getCell(0,1));
        assertEquals("BOR",tab.getCell(1,1));
    }

    public function testCSVWithFinalNewline() {
        var txt = "name,age\nPaul,\"\n\"\n";
        var tab = Native.table([]);
        var csv = new coopy.Csv(',','\n');
        csv.parseTable(txt,tab);
        assertEquals(2,tab.height);
        assertEquals(2,tab.width);
        var out = csv.renderTable(tab);
        assertEquals(txt,out);
    }

    public function testEmpty() {
        var table1 = Native.table(data1);
        var table2 = Native.table([]);
        var alignment = coopy.Coopy.compareTables(table1,table2).align();
        var data_diff = [];
        var table_diff = Native.table(data_diff);
        var flags = new coopy.CompareFlags();
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        var table3 = table1.clone();
        var patcher = new coopy.HighlightPatch(table3,table_diff);
        patcher.apply();
        assertEquals(0,table3.height);
    }


    public function testNestedOutput() {
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var alignment = coopy.Coopy.compareTables(table1,table2).align();
        var data_diff = [];
        var table_diff = Native.table(data_diff);
        var flags = new coopy.CompareFlags();
        flags.allow_nested_cells = true;
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        var update : Dynamic = table_diff.getCell(3,4);
        var view = table_diff.getCellView();
        assertTrue(view.isHash(update));
        assertEquals("Barcelona",view.hashGet(update,"before"));
        assertEquals("Madrid",view.hashGet(update,"after"));
        assertEquals("Barcelona",Native.getHashKey(update,"before"));
        assertEquals("Madrid",Native.getHashKey(update,"after"));
    }

    public function testNestedOutputHtml() {
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var alignment = coopy.Coopy.compareTables(table1,table2).align();
        var table_diff1 = Native.table([]);
        var table_diff2 = Native.table([]);
        var flags = new coopy.CompareFlags();
        var highlighter1 = new coopy.TableDiff(alignment,flags);
        highlighter1.hilite(table_diff1);
        flags.allow_nested_cells = true;
        var highlighter2 = new coopy.TableDiff(alignment,flags);
        highlighter2.hilite(table_diff2);
        var render1 = new coopy.DiffRender().render(table_diff1).html();
        var render2 = new coopy.DiffRender().render(table_diff2).html();
        assertEquals(render1,render2);
    }

    public function testThreeWay() {
        var flags = new coopy.CompareFlags();
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var table3 = Native.table(data3);
        var table4 = Native.table(data4);
        flags.parent = table1;
        var out = coopy.Coopy.diff(table2,table3,flags);
        var table2b = table2.clone();
        coopy.Coopy.patch(table2b,out);
        assertTrue(coopy.SimpleTable.tableIsSimilar(table4,table2b));
    }

    public function testAnsiOutput() {
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var txt = coopy.Coopy.diffAsAnsi(table1, table2);
        assertTrue(txt.indexOf("Germany")>=0);
    }

    public function testHtmlOutput() {
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var txt = coopy.Coopy.diffAsHtml(table1, table2);
        assertTrue(txt.indexOf("Germany")>=0);
    }

    public function testStraySpaceInCsv() {
        var csv = new coopy.Csv();
        var tab = csv.makeTable("id,color\n" +
                                "15,red\n" +
                                "13,mauve,,,\n" +
                                "2,green\n");
        assertEquals(tab.width,2);
    }

    public function testShowChanged() {
        var table1 = Native.table(data1);
        var flags = new coopy.CompareFlags();
        flags.show_unchanged = true;
        var table = coopy.Coopy.diff(table1,table1,flags);
        assertEquals(4,table.height);
        assertEquals(3,table.width);
    }

    public function testCountColumnChanges() {
        var table1 = Native.table(data2);
        var table2 = Native.table(data5);
        var alignment = coopy.Coopy.compareTables(table1,table2).align();
        var data_diff = [];
        var table_diff = Native.table(data_diff);
        var flags = new coopy.CompareFlags();
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        var summary = highlighter.getSummary();
        assertEquals(summary.col_updates,2);
    }

    public function testCountAddAndMoveColumns() {
        var table1 = Native.table(data4);
        var table2 = Native.table(data6);
        var alignment = coopy.Coopy.compareTables(table1,table2).align();
        var data_diff = [];
        var table_diff = Native.table(data_diff);
        var flags = new coopy.CompareFlags();
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        var summary = highlighter.getSummary();
        assertEquals(summary.col_inserts,1);
        assertEquals(summary.col_reorders,1);
        assertEquals(summary.col_deletes,0);
    }

    public function testCountAddAndMoveColumnsReversed() {
        var table1 = Native.table(data6);
        var table2 = Native.table(data4);
        var alignment = coopy.Coopy.compareTables(table1,table2).align();
        var data_diff = [];
        var table_diff = Native.table(data_diff);
        var flags = new coopy.CompareFlags();
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        var summary = highlighter.getSummary();
        assertEquals(summary.col_inserts,0);
        assertEquals(summary.col_reorders,1);
        assertEquals(summary.col_deletes,1);
    }

    public function testQuotedHtml() {
        var table1 = Native.table(data1);
        var table2 = Native.table(data7);
        var alignment = coopy.Coopy.compareTables(table1,table2).align();
        var table_diff = Native.table([]);
        var flags = new coopy.CompareFlags();
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        var dr1 = new coopy.DiffRender();
        var dr2 = new coopy.DiffRender();
        dr2.quoteHtml(false);
        var render1 = dr1.render(table_diff).html();
        var render2 = dr2.render(table_diff).html();
        assertFalse(render1 == render2);
        assertTrue(render1.indexOf("&lt;i&gt;Paris&lt;/i&gt;") != -1);
        assertTrue(render2.indexOf("<i>Paris</i>") != -1);
    }

    public function testIgnoreTypesOfChanges() {
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var flags = new coopy.CompareFlags();
        flags.unchanged_context = 0;
        flags.filter("column", false);
        var data_diff = coopy.Coopy.diff(table1,table2,flags);
        assertEquals(4,data_diff.height);
        flags.filter("insert", false);
        data_diff = coopy.Coopy.diff(table1,table2,flags);
        assertEquals(3,data_diff.height);
        flags.filter("update", false);
        data_diff = coopy.Coopy.diff(table1,table2,flags);
        assertEquals(2,data_diff.height);
        data_diff = coopy.Coopy.diff(table2,table1,flags);
        assertEquals(3,data_diff.height);
        flags.filter("delete", false);
        data_diff = coopy.Coopy.diff(table2,table1,flags);
        assertEquals(2,data_diff.height);
        flags = new coopy.CompareFlags();
        flags.unchanged_context = 0;
        flags.filter("insert", true);
        data_diff = coopy.Coopy.diff(table1,table2,flags);
        assertEquals(3,data_diff.height);
        flags.filter("update", true);
        data_diff = coopy.Coopy.diff(table1,table2,flags);
        assertEquals(4,data_diff.height);
        flags.filter("column", true);
        data_diff = coopy.Coopy.diff(table1,table2,flags);
        assertEquals(6,data_diff.height);
    }

    public function testChangeToBlank() {
        var v1 = Native.table([["id", "name"], ["1", " "]]);
        var v2 = Native.table([["id", "name"], ["1", ""]]);
        var diff = coopy.Coopy.diff(v1,v2);
        assertEquals(" ->", diff.getCell(2,1));
    }

    public function testChangeToNull() {
        var v1 = Native.table([["id", "name"], ["1", ""]]);
        var v2 = Native.table([["id", "name"], ["1", null]]);
        var diff = coopy.Coopy.diff(v1,v2);
        assertEquals("->NULL", diff.getCell(2,1));
    }

    public function testChangeFromNull() {
        var v1 = Native.table([["id", "name"], ["1", null]]);
        var v2 = Native.table([["id", "name"], ["1", ""]]);
        var diff = coopy.Coopy.diff(v1,v2);
        assertEquals("NULL->", diff.getCell(2,1));
    }

    public function testToLiteralStringNull() {
        var v1 = Native.table([["id", "name"], ["1", null]]);
        var v2 = Native.table([["id", "name"], ["1", "NULL"]]);
        var diff = coopy.Coopy.diff(v1,v2);
        assertEquals("NULL->_NULL", diff.getCell(2,1));
    }
}
