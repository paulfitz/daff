// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

interface SqlDatabase {
    function getColumns(name: SqlTableName) : Array<SqlColumn>;

    function getQuotedTableName(name: SqlTableName) : String;
    function getQuotedColumnName(name: String) : String;

    function begin(query: String, ?args: Array<Dynamic>,
                   ?order: Array<String>) : Bool;
    function beginRow(name: SqlTableName, row: Int, ?order: Array<String>) : Bool;
    function read() : Bool;
    function get(index: Int) : Dynamic;
    function end() : Bool;
    function width() : Int;

    // name of rowid/oid/... or null if there is none
    function rowid() : String;

    function getHelper() : SqlHelper;

    // if attaching is possible (basically just for sqlite), return non-null
    function getNameForAttachment() : String;
}
