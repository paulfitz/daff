import coopyhx as daff

class PythonTableView(daff.Table):
    def __init__(self,data):
        self.data = data
        self.height = len(data)
        self.width = 0
        if self.height>0:
            self.width = len(data[0])

    def get_width(self):
        return self.width

    def get_height(self):
        return self.height

    def getCell(self,x,y):
        return self.data[y][x]

    def setCell(self,x,y,c):
        self.data[y][x] = c

    def toString(self):
        return daff.SimpleTable.tableToString(self)

    def getCellView(self):
        return daff.SimpleView()

    def isResizable(self):
        return True

    def resize(self,w,h):
        self.width = w
        self.height = h
        for i in range(len(self.data)):
            row = self.data[i]
            if row == None:
                row = self.data[i] = []
            while len(row)<w:
                row.append(None)
        while len(self.data)<h:
            row = []
            for i in range(w):
                row.append(None)
            self.data.append(row)
        return True

    def clear(self):
        for i in range(len(self.data)):
            row = self.data[i]
            for j in range(len(row)):
                row[j] = None

    def trimBlank(self): 
        return False

    def getData(self):
        return self.data

    def insertOrDeleteRows(self,fate,hfate):
        ndata = []
        for i in range(len(fate)):
            j = fate[i];
            if j!=-1:
                ndata[j] = self.data[i]

        del self.data[:]
        for i in range(len(ndata)):
            self.data[i] = ndata[i]
        self.resize(self.width,hfate)
        return True

    def insertOrDeleteColumns(self,fate,wfate):
        if wfate==self.width and wfate==self.length:
            eq = True
            for i in range(wfate):
                if fate[i]!=i:
                    eq = False
                    break

        if eq:
            return True

        for i in range(self.height):
            row = self.data[i]
            nrow = []
            for j in range(self.width):
                if fate[j]==-1:
                    continue
                nrow[fate[j]] = row[j]
            while nrow.length<wfate:
                nrow.append(None)
            self.data[i] = nrow
        self.width = wfate
        return True

    def isSimilar(self,alt):
        if alt.width!=self.width:
            return False
        if alt.height!=self.height:
            return False
        for c in range(self.width):
            for r in range(self.height):
                v1 = "" + self.getCell(c,r)
                v2 = "" + alt.getCell(c,r) 
                if (v1!=v2):
                    print("MISMATCH "+ v1 + " " + v2);
                    return False
        return True
