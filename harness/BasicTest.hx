// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class BasicTest extends haxe.unit.TestCase {
    var data1 : Array<Array<Dynamic>>;
    var data2 : Array<Array<Dynamic>>;
    var data3 : Array<Array<Dynamic>>;
    var data4 : Array<Array<Dynamic>>;

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

    public function testStraySpaceInCsv() {
        var csv = new coopy.Csv();
        var tab = csv.makeTable("id,color\n" +
                                "15,red\n" +
                                "13,mauve,,,\n" +
                                "2,green\n");
        assertEquals(tab.width,2);
    }
}
