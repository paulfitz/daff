// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class SqlTest extends haxe.unit.TestCase {
    var db : coopy.SqlDatabase;
    var flags : coopy.CompareFlags;

    override public function setup() {
        db = Native.openSqlite(":memory:");
        createTables();
    }

    public function createTables() {
        for (name in ["ver1", "ver2", "ver3", "ver4", "ver5", "ver6", "nully1", "nully2"]) {
            exec(db,"DROP TABLE IF EXISTS "+name);
        }
        exec(db,"CREATE TABLE ver1 (id INTEGER PRIMARY KEY, name TEXT)");
        exec(db,"CREATE TABLE ver2 (id INTEGER PRIMARY KEY, name TEXT)");
        exec(db,"CREATE TABLE ver3 (id INTEGER PRIMARY KEY, name TEXT, count INTEGER)");
        exec(db,"CREATE TABLE ver4 (id INTEGER PRIMARY KEY, count INTEGER)");
        exec(db,"CREATE TABLE ver5 (id INTEGER PRIMARY KEY, happy INTEGER, name TEXT)");
        exec(db,"CREATE TABLE ver6 (id INTEGER PRIMARY KEY, happy INTEGER, name TEXT)");

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

        exec(db,"INSERT INTO ver5 VALUES(?,?,?)",[1, 88, "Paul"]);
        exec(db,"INSERT INTO ver5 VALUES(?,?,?)",[2, 77, "Naomi"]);
        exec(db,"INSERT INTO ver5 VALUES(?,?,?)",[4, 88, "Hobbesian"]);

        exec(db,"INSERT INTO ver6 VALUES(?,?,?)",[2, 77, "Noemi"]);
        exec(db,"INSERT INTO ver6 VALUES(?,?,?)",[3, null, "Calvin"]);
        exec(db,"INSERT INTO ver6 VALUES(?,?,?)",[4, 88, "Hobbesian"]);


        exec(db,"CREATE TABLE nully1 (id INTEGER PRIMARY KEY, happy INTEGER, name TEXT)");
        exec(db,"INSERT INTO nully1 VALUES(?,?,?)",[2, null, null]);

        exec(db,"CREATE TABLE nully2 (id INTEGER PRIMARY KEY, happy INTEGER, name TEXT)");
        exec(db,"INSERT INTO nully2 VALUES(?,?,?)",[2, null, "frog"]);

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
        var sc = new coopy.SqlCompare(db,st1,st2,null);
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

        var sc2 = new coopy.SqlCompare(db,st1,st2,null);
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

    public function comparePair(name1: String, name2: String) {
        createTables();
        var st1 = new coopy.SqlTable(db,new coopy.SqlTableName(name1));
        var st2 = new coopy.SqlTable(db,new coopy.SqlTableName(name2));
        flags.show_meta = true;
        var out = coopy.Coopy.diff(st1,st2,flags);
        coopy.Coopy.patch(st1,out);
        out = coopy.Coopy.diff(st1,st2,flags);
        assertTrue(out.height<=1);
    }

    public function testColumnPatch() {
        var names = ["ver1", "ver2", "ver3", "ver4"];
        for (n1 in names) {
            for (n2 in names) {
                comparePair(n1,n2);
            }
        }
        createTables();
    }

    public function test3WayDiff() {
        var st1 = new coopy.SqlTable(db,new coopy.SqlTableName("ver1"));
        var st2 = new coopy.SqlTable(db,new coopy.SqlTableName("ver2"));
        var st5 = new coopy.SqlTable(db,new coopy.SqlTableName("ver5"));
        var st6 = new coopy.SqlTable(db,new coopy.SqlTableName("ver6"));
        flags.parent = st1;
        var out = coopy.Coopy.diff(st2,st5,flags);
        coopy.Coopy.patch(st2,out);
        assertTrue(coopy.SimpleTable.tableIsSimilar(st2,st6));
    }

    public function testChangeNull1() {
        var nully1 = new coopy.SqlTable(db,new coopy.SqlTableName("nully1"));
        var nully2 = new coopy.SqlTable(db,new coopy.SqlTableName("nully2"));
        var patch = new Array<Array<Dynamic>>();
        patch = [["@@","id","happy","name"],
                 ["->",2,"NULL","NULL->frog"]];
        coopy.Coopy.patch(nully1,Native.table(patch));
        assertTrue(coopy.SimpleTable.tableIsSimilar(nully1,nully2));
    }

    public function testChangeNull2() {
        var nully1 = new coopy.SqlTable(db,new coopy.SqlTableName("nully1"));
        var nully2 = new coopy.SqlTable(db,new coopy.SqlTableName("nully2"));
        var patch = new Array<Array<Dynamic>>();
        patch = [["@@","id","happy","name"],
                 ["->",2,null,"NULL->frog"]];
        coopy.Coopy.patch(nully1,Native.table(patch));
        assertTrue(coopy.SimpleTable.tableIsSimilar(nully1,nully2));
    }
}
