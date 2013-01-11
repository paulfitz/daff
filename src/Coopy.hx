// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class Coopy {
    public static function main() : Int {
        var x : IntHash<String> = new IntHash<String>();
        x.set(1,"hi");
        trace("Hello world");
        trace("1 -> " + x.get(1));
        return 0;
    }
}
