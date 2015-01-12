// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

interface SqlHelper {
    function getTableNames(db: SqlDatabase) : Array<String>;
    function countRows(db: SqlDatabase, name: SqlTableName) : Int;
    function getRowIDs(db: SqlDatabase, name: SqlTableName) : Array<Int>;
}
