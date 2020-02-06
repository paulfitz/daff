// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class MergeTest extends haxe.unit.TestCase {
    var data1 : Dynamic;
    var data2 : Dynamic;
    var data3 : Dynamic;
    var data4 : Dynamic;
    var data2b : Dynamic;
    var data3b : Dynamic;
    var data4b : Dynamic;
    var data4c : Dynamic;

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
        data3 = [['Country','Capital'],
                 ['Dear old Ireland','Dublin'],
                 ['Spain','Barcelona'],
                 ['Finland','Helsinki']];
        data4 = [['Country','Code','Capital'],
                 ['Dear old Ireland','ie','Dublin'],
                 ['Spain','es','Madrid'],
                 ['Finland',null,'Helsinki'],
                 ['Germany','de','Berlin']];
        data2b = [['Country','Code','Capital'],
                 ['Ireland','ie','Dublin'],
                 ['France','fr','Paris'],
                 ['Spain','es','Lisbon'],
                 ['Germany','de','Berlin']];
        data3b = [['Country','Capital'],
                 ['Dear old Ireland','Dublin'],
                 ['Spain','Lisbon'],
                 ['Finland','Helsinki']];
        data4b = [['Country','Code','Capital'],
                  ['Dear old Ireland','ie','Dublin'],
                  ['Spain','es','((( Barcelona ))) Madrid /// Lisbon'],
                  ['Finland',null,'Helsinki'],
                  ['Germany','de','Berlin']];
        data4c = [['Country','Code','Capital'],
                  ['Dear old Ireland','ie','Dublin'],
                  ['Spain','es','Lisbon'],
                  ['Finland',null,'Helsinki'],
                  ['Germany','de','Berlin']];
    }
    
    public function testUnconflicted(){
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var table3 = Native.table(data3);
        var table4 = Native.table(data4);
        var flags = new coopy.CompareFlags();
        var merger = new coopy.Merger(table1,table2,table3,flags);
        var conflicts = merger.apply();
        assertEquals(conflicts,0);
        assertEquals(coopy.SimpleTable.tableToString(table2),
                     coopy.SimpleTable.tableToString(table4));
    }

    public function testConflicted(){
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var table3 = Native.table(data3b);
        var table4 = Native.table(data4b);
        var flags = new coopy.CompareFlags();
        var merger = new coopy.Merger(table1,table2,table3,flags);
        var conflicts = merger.apply();
        assertEquals(conflicts,1);
        assertEquals(coopy.SimpleTable.tableToString(table2),
                     coopy.SimpleTable.tableToString(table4));
    }

    public function testChangedToSameValue(){
        var table1 = Native.table(data1);
        var table2 = Native.table(data2b);
        var table3 = Native.table(data3b);
        var table4 = Native.table(data4c);
        var flags = new coopy.CompareFlags();
        var merger = new coopy.Merger(table1,table2,table3,flags);
        var conflicts = merger.apply();
        assertEquals(conflicts,0);
        assertEquals(coopy.SimpleTable.tableToString(table2),
                     coopy.SimpleTable.tableToString(table4));
    }
}
