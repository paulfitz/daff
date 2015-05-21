// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class MetaTest extends haxe.unit.TestCase {

    public function testMeta() {
        var d1 : Array<Array<Dynamic>> = [["thing", "speed"],
                                          ["me","slow"],
                                          ["train", "fast"]];
        var t1 = Native.table(d1);
        var s = new coopy.SimpleMeta(t1);
        var vals = new Map<String,Dynamic>();
        vals.set("train",1);
        vals.set("me",1);
        s.addColumn("realness",vals);
        vals.set("train","t");
        vals.set("me","m");
        s.addColumn("first_letter",vals);
        s.removeColumn("speed");
        s.renameColumn("thing","object");
        s.moveRow("train",1);
        s.renameRow("train","choo-choo");
        s.setCell("first_letter","choo-choo","c");
        s.moveColumn("first_letter",1);
        assertEquals(t1.width,3);
        assertEquals(t1.height,3);
    }

    public function testMetaTable() {
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

    public function testMetaTable2() {
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
        assertEquals(t1alt.height,3);
        coopy.Coopy.patch(t1c,diff);
        assertEquals(t1c.height,3);
    }

    public function testMetaTable3() {
        var d1 : Array<Array<Dynamic>> = [ ["@@", "age", "name"],
                                           ["@precision",10,4],
                                           ["@type","int","string"],
                                           [null,77,"Peter"],
                                           [null,111,"Mary"] ];
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
        var t3 = t1.clone();
        var t3c = new coopy.CombinedTable(t3);
        coopy.Coopy.patch(t3c,diff);
        assertTrue(coopy.SimpleTable.tableIsSimilar(t2,t3));
    }
}
