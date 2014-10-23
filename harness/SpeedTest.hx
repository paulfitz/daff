// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class SpeedTest extends haxe.unit.TestCase {
    var data1 : Array<Array<Dynamic>>;
    var data2 : Array<Array<Dynamic>>;

    override public function setup() {
        data1 = [];
        data2 = [];
        var scale = 10000;
#if enbiggen
        scale = 50000;
#end
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
#if enbiggen
                var ct = ((i+k*7)%10001);
                for (j in 0...40) {
                    row.push("" + ct);
                    ct = ((i+ct+k*7)%10001);
                }
#end
            }
        }
    }

    public function testMedium() {
        var table1 = Native.table(data1);
        var table2 = Native.table(data2);
#if enbiggen
        trace("table size is " + table1.get_height() + " x " + table1.get_width());
#end
        var flags = new coopy.CompareFlags();
        flags.unchanged_column_context = 3;
        var align = coopy.Coopy.compareTables(table1,table2).align();
        var diff = Native.table([]);
        var highlighter = new coopy.TableDiff(align,flags);
        flags.ordered = false;
        highlighter.hilite(diff);
        assertEquals(1,1); // goal is just to complete in reasonable time
    }
}
