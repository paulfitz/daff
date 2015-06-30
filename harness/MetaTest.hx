// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class MetaTest extends haxe.unit.TestCase {

    public function testMetaTable() {
        var t1 = new coopy.SimpleTable(3,2);
        t1.setCell(0,0,"name");
        t1.setCell(1,0,"age");
        t1.setCell(2,0,"fruit");
        t1.setCell(0,1,"Peter");
        t1.setCell(1,1,"88");
        t1.setCell(2,1,"apple");
        var m1 = new coopy.SimpleMeta(t1);
        t1.setMeta(m1);
        m1.addMetaData("name","precision",4);
        m1.addMetaData("name","type","string");
        m1.addMetaData("age","precision",10);
        m1.addMetaData("age","type","int");
        m1.addMetaData("fruit","type","list");
        var t2 : coopy.SimpleTable = cast t1.clone();
        var m2 : coopy.SimpleMeta = cast t2.getMeta();
        m2.addMetaData("age","type","string");
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

    public function testRowChange() {
        var diff = Native.table([['@@', 'id', 'name'],
                                 ['+++', 3, 'Calvin'],
                                 ['->', 2, 'Naomi->Noemi'],
                                 ['---', 1, 'Paul']]);
        var o = new coopy.SimpleTable(0,0);
        var m = new coopy.SimpleMeta(o);
        o.setMeta(m);
        var lst = new Array<coopy.RowChange>();
        m.storeRowChanges(lst);
        coopy.Coopy.patch(o,diff);
        assertEquals(lst.length,3);
    }
}
