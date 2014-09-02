// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class Main {

    static public function main(){
        var r = new haxe.unit.TestRunner();
        r.add(new BasicTest());
        r.add(new MergeTest());
        r.add(new SpeedTest());
        r.run();
    }
}
