// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class Main {

    static public function main() {
        var r = new haxe.unit.TestRunner();
        var cases = [
                     new BasicTest(), 
                     new MergeTest(), 
                     new TypeTest(), 
                     new RowOrderTest(), 
                     new SmallTableTest(), 
                     new SpeedTest(), 
                     new JsonTest(), 
                     new MetaTest()
                     ];

        var filter = "";
        for (c in cases) {
            var name = Type.getClassName(Type.getClass(c));
            if (filter=="" || name.indexOf(filter)>=0) {
                r.add(c);
            }
        }
        var ok = r.run();
        if (!ok) {
            Native.exit(1);
        }
    }
}
