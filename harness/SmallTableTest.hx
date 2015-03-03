// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class SmallTableTest extends haxe.unit.TestCase {
    var data1 : Dynamic;
    var data2 : Dynamic;

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
        var table1 = Native.table(e1);
        var table2 = Native.table(e2);
        var data_diff = [];
        var table_diff = Native.table(data_diff);
        var flags = new coopy.CompareFlags();
        var alignment = coopy.Coopy.compareTables(table1,table2,flags).align();
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        assertEquals(table_diff.get_height(),2);
        var table3 = table1.clone();
        var patcher = new coopy.HighlightPatch(table3,table_diff);
        patcher.apply();
        assertTrue(coopy.SimpleTable.tableIsSimilar(table3,table2));
    }
}
