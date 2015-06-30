// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class SqlTest extends haxe.unit.TestCase {
    var db : coopy.SqlDatabase;
    var flags : coopy.CompareFlags;

    override public function setup() {
        db = Native.openSqlite(":memory:");
        exec(db,"CREATE TABLE ver1 (id INTEGER PRIMARY KEY, name TEXT)");
        exec(db,"CREATE TABLE ver2 (id INTEGER PRIMARY KEY, name TEXT)");
        exec(db,"CREATE TABLE ver3 (id INTEGER PRIMARY KEY, name TEXT, count INTEGER)");
        exec(db,"CREATE TABLE ver4 (id INTEGER PRIMARY KEY, count INTEGER)");
        exec(db,"INSERT INTO ver1 VALUES(?,?)",[1, "Paul"]);
        exec(db,"INSERT INTO ver1 VALUES(?,?)",[2, "Naomi"]);
        exec(db,"INSERT INTO ver1 VALUES(?,?)",[4, "Hobbes"]);
        exec(db,"INSERT INTO ver2 VALUES(?,?)",[2, "Noemi"]);
        exec(db,"INSERT INTO ver2 VALUES(?,?)",[3, "Calvin"]);
        exec(db,"INSERT INTO ver2 VALUES(?,?)",[4, "Hobbes"]);
        exec(db,"INSERT INTO ver3 VALUES(?,?,?)",[2, "Noemi", 20]);
        exec(db,"INSERT INTO ver3 VALUES(?,?,?)",[3, "Calvin", 50]);
        exec(db,"INSERT INTO ver3 VALUES(?,?,?)",[4, "Hobbes", 92]);
        exec(db,"INSERT INTO ver4 VALUES(?,?)",[2, 20]);
        exec(db,"INSERT INTO ver4 VALUES(?,?)",[3, 50]);
        exec(db,"INSERT INTO ver4 VALUES(?,?)",[4, 92]);
        flags = new coopy.CompareFlags();
        flags.diff_strategy = "sql";
        flags.show_meta = false;
    }

    private function exec(db: coopy.SqlDatabase, query: String, ?args: Array<Dynamic>) {
        db.begin(query,args);
        db.end();
    }

    public function testRowDiffAndPatch() {

        var st1 = new coopy.SqlTable(db,new coopy.SqlTableName("ver1"));
        var st2 = new coopy.SqlTable(db,new coopy.SqlTableName("ver2"));
        var sc = new coopy.SqlCompare(db,st1,st2);
        var alignment = sc.apply();
    
        var flags = new coopy.CompareFlags();
        var td = new coopy.TableDiff(alignment,flags);
        var out = Native.table([]);
        td.hilite(out);

        var target = Native.table([['@@', 'id', 'name'],
                                   ['+++', 3, 'Calvin'],
                                   ['->', 2, 'Naomi->Noemi'],
                                   ['---', 1, 'Paul']]);
        assertTrue(coopy.SimpleTable.tableIsSimilar(target,out));
        coopy.Coopy.patch(st1,target);

        var sc2 = new coopy.SqlCompare(db,st1,st2);
        var alignment2 = sc2.apply();
        var td = new coopy.TableDiff(alignment2,flags);
        var out2 = Native.table([]);
        td.hilite(out2);
        assertTrue(out2.height == 1);
    }

    public function testColumnDiff() {
        var st1 = new coopy.SqlTable(db,new coopy.SqlTableName("ver1"));
        var st3 = new coopy.SqlTable(db,new coopy.SqlTableName("ver3"));
        var st4 = new coopy.SqlTable(db,new coopy.SqlTableName("ver4"));
        var out = coopy.Coopy.diff(st1,st3,flags);
        assertEquals(50,out.getCell(3,2));
        out = coopy.Coopy.diff(st3,st1,flags);
        assertEquals(50,out.getCell(3,4));
        out = coopy.Coopy.diff(st1,st4,flags);
        assertEquals("+",out.getCell(0,3));
        assertEquals(2,out.getCell(1,3));
        assertEquals(20,out.getCell(2,3));
        assertEquals("Naomi",out.getCell(3,3));
    }
}
