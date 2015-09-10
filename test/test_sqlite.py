import daff

db = daff.sqlite3.connect(':memory:')
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

sd = daff.SqliteDatabase(db,None)

st1 = daff.SqlTable(sd,daff.SqlTableName("ver1"))
st2 = daff.SqlTable(sd,daff.SqlTableName("ver2"))

sc = daff.SqlCompare(sd,st1,st2,None)

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
