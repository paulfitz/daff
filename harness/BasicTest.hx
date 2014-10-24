// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class BasicTest extends haxe.unit.TestCase {
    var data1 : Array<Array<Dynamic>>;
    var data2 : Array<Array<Dynamic>>;

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
}
