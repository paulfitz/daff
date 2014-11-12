// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class SqlColumn {
    public var name : String;
    public var primary : Bool;

    public function new() {}

    public static function byNameAndPrimaryKey(name: String, primary: Bool) {
        var result : SqlColumn = new SqlColumn();
        result.name = name;
        result.primary = primary;
        return result;
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
