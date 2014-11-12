// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class SqlTableName {
    public var name : String;
    public var prefix : String;

    public function new(name: String = "", prefix: String = "") {
        this.name = name;
        this.prefix = prefix;
    }

    public function toString() {
        if (prefix=="") return name;
        return prefix + "." + name;
    }
}

