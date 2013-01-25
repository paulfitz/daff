// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class Coopy {
    public static function main() : Int {
        var x : IntHash<String> = new IntHash<String>();
        x.set(1,"hi");
        trace("Hello world");
        trace("1 -> " + x.get(1));

        var y : Hash<String> = new Hash<String>();
        y.set("hello","world");
        trace("hash " + y);
        trace("hello - " + y.get("hello"));

        var s : Store = new Store();
        trace(s.frog == null);
        s.frog = "space";
        trace(s.frog);
        trace(s);

        return 0;
    }
}
