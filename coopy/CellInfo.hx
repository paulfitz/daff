// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class CellInfo {
    public var value : String;
    public var pretty_value : String;
    public var category : String;
    public var category_given_tr : String;

    public function new() : Void {}
}
