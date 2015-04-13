// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class MetaTest extends haxe.unit.TestCase {
    public function testMeta() {
        var t1 = new coopy.SimpleTable(3,2);
        t1.setCell(0,0,"name");
        t1.setCell(1,0,"age");
        t1.setCell(2,0,"fruit");
        t1.setCell(0,1,"Peter");
        t1.setCell(1,1,"88");
        t1.setCell(2,1,"apple");
        t1.addMetaData("name","precision",4);
        t1.addMetaData("name","type","string");
        t1.addMetaData("age","precision",10);
        t1.addMetaData("age","type","int");
        t1.addMetaData("fruit","type","list");
        var t2 : coopy.SimpleTable = cast t1.clone();
        t2.addMetaData("age","type","string");
        t2.setCell(0,1,"Pan");
        var flags = new coopy.CompareFlags();
        var alignment = coopy.Coopy.compareTables(t1,t2,flags).align();
        var highlighter = new coopy.TableDiff(alignment,flags);
        var table_diff = new coopy.SimpleTable(0,0);
        highlighter.hilite(table_diff);
        assertEquals(table_diff.height,3);
    }

    public function testMeta2() {
        var d1 : Array<Array<Dynamic>> = [ ["@@", "name", "age"],
                                           ["@precision",4,10],
                                           ["@type","string","int"],
                                           [null,"Peter",77],
                                           [null,"Mary",111] ];
        var d2 : Array<Array<Dynamic>> = [ ["@@", "name", "age", "fruit"],
                                           ["@precision",14,10,null],
                                           ["@type","string","int","list"],
                                           [null,"Peter",88,"apple"],
                                           [null,"Mary",111,"orange"]
                                           ];
        var t1 = Native.table(d1);
        var t2 = Native.table(d2);
        var t1c = new coopy.CombinedTable(t1);
        var t2c = new coopy.CombinedTable(t2);
        var diff = coopy.Coopy.diff(t1c,t2c);
        assertEquals(diff.height,6);
        var t1alt = Native.table([["name","age"],["Peter",77],["Mary",111]]);
        coopy.Coopy.patch(t1alt,diff);
        assertEquals(t1c.height,3);
        coopy.Coopy.patch(t1c,diff);
        assertEquals(t1c.height,3);
    }
}
