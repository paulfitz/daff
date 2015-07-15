// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

interface SqlHelper {
    function getTableNames(db: SqlDatabase) : Array<String>;
    function countRows(db: SqlDatabase, name: SqlTableName) : Int;
    function getRowIDs(db: SqlDatabase, name: SqlTableName) : Array<Int>;
    function insert(db: SqlDatabase, name: SqlTableName, vals: Map<String, Dynamic>) : Bool;
    function delete(db: SqlDatabase, name: SqlTableName, conds: Map<String, Dynamic>) : Bool;
    function update(db: SqlDatabase, name: SqlTableName, 
                    conds: Map<String, Dynamic>,
                    vals: Map<String, Dynamic>) : Bool;
    function attach(db: SqlDatabase, tag: String, resource_name: String) : Bool;
    function alterColumns(db: SqlDatabase, name: SqlTableName, columns : Array<ColumnChange>) : Bool;
}
