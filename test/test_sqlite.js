var fs = require('fs');
var daff = require('daff');
var assert = require('assert');

var Fiber = null;
var sqlite3 = null;
try {
    Fiber = require('fibers');
    sqlite3 = require('sqlite3');
} catch (err) {
    // We don't have what we need for accessing the sqlite database.
    // Not an error.
    console.log("No sqlite3/fibers");
    return;
}

Fiber(function() {
    var sql = new SqliteDatabase(new sqlite3.Database(':memory:'),null,Fiber);
    sql.exec("CREATE TABLE ver1 (id INTEGER PRIMARY KEY, name TEXT)");
    sql.exec("CREATE TABLE ver2 (id INTEGER PRIMARY KEY, name TEXT)");
    sql.exec("INSERT INTO ver1 VALUES(?,?)",[1, "Paul"]);
    sql.exec("INSERT INTO ver1 VALUES(?,?)",[2, "Naomi"]);
    sql.exec("INSERT INTO ver1 VALUES(?,?)",[4, "Hobbes"]);
    sql.exec("INSERT INTO ver2 VALUES(?,?)",[2, "Noemi"]);
    sql.exec("INSERT INTO ver2 VALUES(?,?)",[3, "Calvin"]);
    sql.exec("INSERT INTO ver2 VALUES(?,?)",[4, "Hobbes"]);

    var st1 = new daff.SqlTable(sql,"ver1")
    var st2 = new daff.SqlTable(sql,"ver2")
    var sc = new daff.SqlCompare(sql,st1,st2)
    var alignment = sc.apply();
    
    var flags = new daff.CompareFlags();
    var td = new daff.TableDiff(alignment,flags);
    var out = new daff.TableView([]);
    td.hilite(out);

    var target = new daff.TableView([['@@', 'id', 'name'],
				     ['+++', 3, 'Calvin'],
				     ['->', 2, 'Naomi->Noemi'],
				     ['---', 1, 'Paul']]);
    assert(target.isSimilar(out));
}).run();
