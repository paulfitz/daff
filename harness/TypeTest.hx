// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class TypeTest extends haxe.unit.TestCase {
  public function testPrimitives() {
    var data1 : Array<Dynamic> = [
				  ["id","color","length"],
				  [15,"Red",11.2]
				  ];
    var table1 = Native.table(data1);
    var flags = new coopy.CompareFlags();
    var align = coopy.Coopy.compareTables(table1,table1).align();
    var diff = Native.table([]);
    var highlighter = new coopy.TableDiff(align,flags);
    flags.ordered = false;
    highlighter.hilite(diff);
    assertEquals(1,1); // goal is just to complete without php crashing
  }

  public function testList() {
    var data1 : Array<Dynamic> = [
				  ["id","color","length"],
				  [15,"Red",11.2]
				  ];
    var table1 = Native.table(data1);
    var flags = new coopy.CompareFlags();
    var align = coopy.Coopy.compareTables(table1,table1).align();
    var diff = Native.table([]);
    var highlighter = new coopy.TableDiff(align,flags);
    flags.always_show_order = true;
    flags.never_show_order = false;
    highlighter.hilite(diff);
    if (diff.getData()!=null) {
        assertTrue(Native.isList(diff.getData()));
        assertTrue(Native.isList(Native.row(diff.getData(),0)));
        assertTrue(Native.isList(Native.row(diff.getData(),1)));
    }
  }
}
