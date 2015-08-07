// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class PatchTest extends haxe.unit.TestCase {
    var data1 : Array<Array<Dynamic>>;
    var data2 : Array<Array<Dynamic>>;
    var data3 : Array<Array<Dynamic>>;
    var data4 : Array<Array<Dynamic>>;
    var table1 : coopy.Table;
    var table2 : coopy.Table;
    var table3 : coopy.Table;
    var table4 : coopy.Table;

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
        data3 = [['Country','Code','Capital'],
                 ['Ireland','ie','Baile Atha Cliath'],
                 ['France','fr','Paris'],
                 ['Spain','es','Madrid'],
                 ['Germany','de','Berlin']];
        data4 = [['Country','Capital'],
                 ['Ireland','Baile Atha Cliath'],
                 ['France','Paris'],
                 ['Spain','Barcelona']];
        table1 = Native.table(data1);
        table2 = Native.table(data2);
        table3 = Native.table(data3);
        table4 = Native.table(data4);
    }
    
    public function testTwoColOnThreeCol(){
        var diff = coopy.Coopy.diff(table1,table4);
        var t = table2.clone();
        var patcher = new coopy.HighlightPatch(t,diff);
        patcher.apply();
        assertTrue(coopy.SimpleTable.tableIsSimilar(t,table3));
    }

    public function testThreeColOnTwoCol(){
        var diff = coopy.Coopy.diff(table2,table3);
        var t = table1.clone();
        var patcher = new coopy.HighlightPatch(t,diff);
        patcher.apply();
        assertTrue(coopy.SimpleTable.tableIsSimilar(t,table4));
    }
}
