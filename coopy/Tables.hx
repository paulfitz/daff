// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class Tables {
    private var template : Table;
    private var tables : Map<String, Table>;
    private var table_order : Array<String>;

    public var alignment: Alignment;

    public function new(template : Table) {
        this.template = template;
        this.tables = new Map<String,Table>();
        this.table_order = new Array<String>();
    }

    public function add(name : String) : Table {
        var t = template.clone();
        tables.set(name,t);
        table_order.push(name);
        return t;
    }

    public function getOrder() : Array<String> {
        return table_order;
    }

    public function get(name : String) : Table {
        return tables.get(name);
    }

    public function one() : Table {
        return tables.get(table_order[0]);
    }

    public function hasInsDel() {
        if (alignment==null) return false;
        if (alignment.has_addition) return true;
        if (alignment.has_removal) return true;
        return false;
    }
}
