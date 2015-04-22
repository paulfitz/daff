// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class SmallTableTest extends haxe.unit.TestCase {
    var data1 : Dynamic;
    var data2 : Dynamic;

    public function checkDiff(e1: Array<Dynamic>,
                              e2: Array<Dynamic>,
                              verbose: Bool = false) : coopy.Table {
        var table1 = Native.table(e1);
        var table2 = Native.table(e2);
        var data_diff = [];
        var table_diff : coopy.Table = Native.table(data_diff);
        var flags = new coopy.CompareFlags();
        var alignment = coopy.Coopy.compareTables(table1,table2,flags).align();
        if (verbose) trace("Alignment: " + alignment);
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        if (verbose) trace("Diff: " + table_diff);

        // while we are at it, make sure coopy.diff works the same way
        var o = coopy.Coopy.diff(table1,table2);
        assertTrue(coopy.SimpleTable.tableIsSimilar(table_diff,o));

        var table3 = table1.clone();
        var patcher = new coopy.HighlightPatch(table3,table_diff);
        patcher.apply();
        if (verbose) trace("Desired " + table2.height + "x" + table2.width + ": " + table2);
        if (verbose) trace("Got " + table3.height + "x" + table3.width + ": " + table3);
        if (verbose) trace("Base " + table1.height + "x" + table1.width + ": " + table1);
        assertTrue(coopy.SimpleTable.tableIsSimilar(table3,table2));
        return table_diff;
    }

    override public function setup() {
        data1 = [['NAME','AGE'],
                 ['Paul','15'],
                 ['Sam','89']];
        data2 = [['key','version','NAME','AGE'],
                 ['ci1f5egka00009xmh16ya9ok5','1','Paul','15'],
                 ['ci1f5egkj00019xmhoiqjd5ui','1','Sam','89']];
    }

    public function testSmall(){
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var alignment = coopy.Coopy.compareTables3(table2,table1,table2).align();
        var data_diff = [];
        var table_diff = Native.table(data_diff);
        var flags = new coopy.CompareFlags();
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        assertEquals(table_diff.get_height(),1);
    }

    public function testIgnore(){
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var flags = new coopy.CompareFlags();
        flags.columns_to_ignore = ["key","version"];
        var alignment = coopy.Coopy.compareTables3(table2,table1,table2,flags).align();
        var data_diff = [];
        var table_diff = Native.table(data_diff);
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        assertEquals(table_diff.get_height(),1);
        assertEquals(table_diff.get_width(),3);
        var v = table1.getCellView();
        assertEquals(v.toString(table_diff.getCell(0,0)),"@@");
        assertEquals(v.toString(table_diff.getCell(1,0)),"NAME");
        assertEquals(v.toString(table_diff.getCell(2,0)),"AGE");
    }

    public function testIssueDaffPhp15() {
        var e1 : Array<Dynamic> =
            [['col1', 'col2', 'col3', 'col4', 'col5', 'col6'],
             [0, 0, 0, 0, 2, 0]];
        var e2 : Array<Dynamic> =
            [['col1', 'col2', 'col3', 'col4', 'col5', 'col6'],
             [0, 0, 0, 0, 1, 0]];
        var table_diff = checkDiff(e1,e2);
        assertEquals(table_diff.get_height(),2);
    }

    public function testIssueDaffPhp16() {
        var objs : Array<Dynamic> = ['xxx', 1];
        for (o in objs) {
            var e1 : Array<Dynamic> =
                [['col1', 'col2', 'col3', 'col4', 'col5'],
                 [0, 0, 0, 0, 0]];
            var e2 : Array<Dynamic> =
                [['col1', 'col2', 'col3', 'col4', 'col5'],
                 [o, 0, 0, 0, 0]];
            var table_diff = checkDiff(e1,e2);
            assertEquals(table_diff.get_height(),2);
            assertEquals(table_diff.getCell(0,1),"->");
            assertEquals(table_diff.getCell(1,1),"0->" + o);
        }
    }

    public function testHeaderLikeRow() {
        var e1 : Array<Dynamic> =
            [['name1','name2'],
             [0, 0],
             ['name1','name2']];
        var e2 : Array<Dynamic> =
            [['name1','name2'],
             ['name1','name2'],
             [0, 0]];
        checkDiff(e1,e2);
    }

    public function testIssueDaffPhp17() {
        var e1 : Array<Dynamic> = [["fd", "df"],
                                   ["fd", "fd"],
                                   [null, "fd"],
                                   ["fd", null]];
        var e2 : Array<Dynamic> = [["A", "new_column_2"],
                                   [null, null],
                                   ["fd", "df"],
                                   ["fd", "fd"]];
        checkDiff(e1,e2);
    }

    public function testIssueDaffPhp17Edit() {
        var e1 : Array<Dynamic> = [["fd", "df"],
                                   ["fd", "fd"],
                                   [null, "fd"]];
        var e2 : Array<Dynamic> = [["A", "new_column_2"],
                                   [null, null],
                                   ["fd", "df"]];
        checkDiff(e1,e2);
    }

    public function testIssueDaffPhp14() {
        var e1 : Array<Dynamic> = [[ "A", "new_column_2" ],
                                   [ "dfdf", null ],
                                   [ null, null ],
                                   [ "xxx", null ],
                                   [ "yyy", null ],
                                   [ null, null ],
                                   [ "fd", null ],
                                   [ "f", null ],
                                   [ "d", null ],
                                   [ "fdf", null ],
                                   [ null, null ],
                                   [ 4, null ],
                                   [ 545, null ],
                                   [ 4, null ],
                                   [ 5, null ],
                                   [ 4, null ],
                                   [ 5, null ],
                                   [ 45, null ],
                                   [ 4, null ],
                                   [ 54, null ],
                                   [ 5, null ],
                                   [ null, null ],
                                   [ null, null ],
                                   [ null, null ],
                                   [ null, null ],
                                   [ null, null ],
                                   [ 454, null ],
                                   [ null, null ],
                                   [ null, null ],
                                   [ 4, null ],
                                   [ 5, null ]];

        var e2 : Array<Dynamic> = [[ "A", "new_column_2" ],
                                   [ "dfdf", null ],
                                   [ null, null ],
                                   [ "fd", null ],
                                   [ "fd", null ],
                                   [ null, null ],
                                   [ "fd", null ],
                                   [ "f", null ],
                                   [ "d", null ],
                                   [ "fdf", null ],
                                   [ null, null ],
                                   [ 4, null ],
                                   [ 545, null ],
                                   [ 4, null ],
                                   [ 5, null ],
                                   [ 4, null ],
                                   [ 5, null ],
                                   [ 45, null ],
                                   [ 4, null ],
                                   [ 54, null ],
                                   [ 5, null ],
                                   [ null, null ],
                                   [ null, null ],
                                   [ null, null ],
                                   [ null, null ],
                                   [ null, null ],
                                   [ 454, null ],
                                   [ null, null ],
                                   [ null, null ],
                                   [ 4, null ],
                                   [ 5, null ]];
        checkDiff(e1,e2);
    }

    public function testStartFromBlank() {
        var e1 : Array<Dynamic> = [];
        var e2 : Array<Dynamic> =
            [['col1', 'col2', 'col3'],
             [1,2,3]];
        var table_diff = checkDiff(e1,e2);
        assertEquals(table_diff.get_height(),3);
    }
}
