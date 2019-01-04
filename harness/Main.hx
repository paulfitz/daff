// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class Main {

    public function new() {
    }

    public function body() {
        var r = new haxe.unit.TestRunner();
        var cases = [
                     new BasicTest(), 
                     new MergeTest(), 
                     new TypeTest(), 
                     new RowOrderTest(), 
                     new SmallTableTest(), 
                     new SpeedTest(), 
                     new JsonTest(), 
                     new MetaTest(),
                     new PatchTest(),
                     new EqualityTest()
                     ];

        if (Native.hasSqlite()) {
            cases.push(new SqlTest());
        }

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

    static public function main() {
        // php version workaround from https://github.com/HaxeFoundation/hscript/commit/dffa3345d0e2b154efd70251aef03193ae7a95c1
        #if ((haxe_ver < 4) && php)
            // uncaught exception: The each() function is deprecated. This message will be suppressed on further calls (errno: 8192)
            untyped __php__("error_reporting(E_ALL ^ E_DEPRECATED);");
		#end
        var main = new Main();
        if (!Native.wrap(main)) {
            main.body();
        }
    }
}
