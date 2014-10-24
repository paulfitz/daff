// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class RowOrderTest extends haxe.unit.TestCase {
    public function testRowOrder(){
        var data1 = [['Country','Capital'],
                     ['Ireland','Dublin'],
                     ['France','Paris'],
                     ['Spain','Barcelona']];
        var data2 = [['Country','Code','Capital'],
                     ['Ireland','ie','Dublin'],
                     ['France','fr','Paris'],
                     ['Spain','es','Madrid'],
                     ['Germany','de','Berlin']];
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var alignment = coopy.Coopy.compareTables(table1,table2).align();
        var data_diff = [];
        var table_diff = Native.table(data_diff);
        var flags = new coopy.CompareFlags();
        flags.always_show_order = true;
        flags.never_show_order = false;
        var highlighter = new coopy.TableDiff(alignment,flags);
        highlighter.hilite(table_diff);
        assertEquals("-:4",table_diff.getCell(0,6));
    }
}
