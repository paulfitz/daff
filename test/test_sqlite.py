import daff
import sqlite3 as sqlite

class SqliteDatabase(daff.SqlDatabase):
    def __init__(self,db):
        self.db = db
        self.cursor = db.cursor()
        self.row = None

    # needed because pragmas do not support bound parameters
    def getQuotedColumnName(self,name):
        return name  # adequate for test, not real life

    # needed because pragmas do not support bound parameters
    def getQuotedTableName(self,name):
        return name.toString()  # adequate for test, not real life

    def getColumns(self,name):
        qname = self.getQuotedTableName(name)
        info = self.cursor.execute("pragma table_info(%s)"%qname).fetchall()
        return [daff.SqlColumn.byNameAndPrimaryKey(x[1],x[5]>0) for x in info]

    def begin(self,query,args=[],order=[]):
        self.cursor.execute(query,args or [])
        return True

    def beginRow(self,tab,row,order=[]):
        self.cursor.execute("SELECT * FROM " + self.getQuotedTableName(tab) + " WHERE rowid = ?",[row])
        return True

    def read(self):
        self.row = self.cursor.fetchone()
        return self.row!=None

    def get(self,index):
        v = self.row[index]
        if v is None:
            return v
        return v

    def end(self):
        pass

    def rowid(self):
        return "rowid"

db = sqlite.connect(':memory:')
c = db.cursor()

c.execute("CREATE TABLE ver1 (id INTEGER PRIMARY KEY, name TEXT)")
c.execute("CREATE TABLE ver2 (id INTEGER PRIMARY KEY, name TEXT)")
data = [(1, "Paul"),
        (2, "Naomi"),
        (4, "Hobbes")]
c.executemany('INSERT INTO ver1 VALUES (?,?)', data)
data = [(2, "Noemi"),
        (3, "Calvin"),
        (4, "Hobbes")]
c.executemany('INSERT INTO ver2 VALUES (?,?)', data)

sd = SqliteDatabase(db)

st1 = daff.SqlTable(sd,daff.SqlTableName("ver1"))
st2 = daff.SqlTable(sd,daff.SqlTableName("ver2"))

sc = daff.SqlCompare(sd,st1,st2)

align = sc.apply()

flags = daff.CompareFlags()
td = daff.TableDiff(align,flags)
out = daff.PythonTableView([])
td.hilite(out)

target = daff.PythonTableView([['@@', 'id', 'name'],
                               ['+++', 3, 'Calvin'],
                               ['->', 2, 'Naomi->Noemi'],
                               ['---', 1, 'Paul']])
assert(target.isSimilar(out))
