// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class SmallTableTest extends haxe.unit.TestCase {
    public function testSmall(){
        var data1 = [['NAME','AGE'],
                     ['Paul','15'],
                     ['Sam','89']];
        var data2 = [['key','version','NAME','AGE'],
                     ['ci1f5egka00009xmh16ya9ok5','1','Paul','15'],
                     ['ci1f5egkj00019xmhoiqjd5ui','1','Sam','89']];
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
    
}
