// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

class TextOverlap {
    public var text : String;
    public var l : Int;
    public var r : Int;
    
    public function new(text: String, l: Int, r: Int) {
        this.text = text;
        this.l = l;
        this.r = r;
    }
    
    public function toString() : String {
        return "{" + l + "|" + text + "|" + r + "}";
    }
}
