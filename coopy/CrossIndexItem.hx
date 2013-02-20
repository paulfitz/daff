// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

class CrossIndexItem {
    public var act : Int;
    public var bct : Int;
    public var as : IntHash<Int>;
    public var bs : IntHash<Int>;

    public function new() : Void {
        act = 0;
        bct = 0;
    }
}
