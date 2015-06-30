// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class SqlColumn {
    public var name : String;
    public var primary : Bool;
    public var type_value : String;
    public var type_family : String;

    public function new() {
        name = "";
        primary = false;
        type_value = null;
        type_family = null;
    }

    public function setName(name: String) {
        this.name = name;
    }

    public function setPrimaryKey(primary: Bool) {
        this.primary = primary;
    }

    public function setType(value: String, family: String) {
        this.type_value = value;
        this.type_family = family;
    }

    public function getName() : String {
        return name;
    }
    
    public function isPrimaryKey() : Bool {
        return primary;
    }

    public function toString() : String {
        return (primary?"*":"") + name;
    }
}
