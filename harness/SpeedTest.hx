// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class SpeedTest extends haxe.unit.TestCase {
    var data1 : Dynamic;
    var data2 : Dynamic;

    override public function setup() {
        data1 = [];
        data2 = [];
        var scale = 10000;
        for (k in 0...2) {
            for (i in 0...scale) {
                var row = [];
                row.push("<supplier>");
                row.push("<product_code>");
                row.push("" + (i+k*7));
                row.push("" + ((i+k*7) % 10));
                row.push("GBP");
                if (k==1) {
                    data1.push(row);
                } else {
                    data2.push(row);
                }
            }
        }
        data2 = data1;
    }

    public function testMedium() {
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
        var flags = new coopy.CompareFlags();
        var align = coopy.Coopy.compareTables(table1,table2).align();
        var diff = Native.table([]);
        var highlighter = new coopy.TableDiff(align,flags);
        highlighter.hilite(diff);
        assertEquals(1,1);
    }
}
