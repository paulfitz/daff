class SqliteDatabase(SqlDatabase):
    def __init__(self,db,fname):
        import sqlite3
        if not hasattr(db, 'cursor'):
            db = sqlite3.connect(db)
        self.db = db
        db.isolation_level = None
        self.fname = fname
        self.cursor = db.cursor()
        self.row = None
        # quoting rule for CSV is compatible with Sqlite
        self.quoter = Csv()
        self.view = SimpleView()

    # needed because pragmas do not support bound parameters
    def getQuotedColumnName(self,name):
        if hasattr(name,'decode'):
            name = unicode(name)
        return self.quoter.renderCell(self.view, name, True)

    # needed because pragmas do not support bound parameters
    def getQuotedTableName(self,name):
        return self.quoter.renderCell(self.view, name.toString(), True)

    def getColumns(self,name):
        qname = self.getQuotedTableName(name)
        info = self.cursor.execute("pragma table_info(%s)"%qname).fetchall()
        columns = []
        for row in info:
            column = SqlColumn()
            column.setName(row[1])
            column.setPrimaryKey(row[5]>0)
            column.setType(row[2],'sqlite')
            columns.append(column)
        return columns

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

    def getHelper(self):
        return SqliteHelper()
    
    def getNameForAttachment(self):
        return self.fname
