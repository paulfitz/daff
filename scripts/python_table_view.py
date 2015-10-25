
class PythonCellView(View):
    def __init__(self):
        pass

    def toString(self,d):
        return str(d) if (d!=None) else ""

    def equals(self,d1,d2):
        return str(d1) == str(d2)

    def toDatum(self,d):
        return d

    def makeHash(self):
        return {}

    def isHash(self,d):
        return type(d) is dict

    def hashSet(self,d,k,v):
        d[k] = v
        
    def hashGet(self,d,k):
        return d[k]

    def hashExists(self,d,k):
        return k in d


class PythonTableView(Table):
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
        return SimpleTable.tableToString(self)

    def getCellView(self):
        return PythonCellView()
        # return SimpleView()

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
        self.width = 0
        self.height = 0

    def trimBlank(self): 
        return False

    def getData(self):
        return self.data

    def insertOrDeleteRows(self,fate,hfate):
        ndata = []
        for i in range(len(fate)):
            j = fate[i];
            if j!=-1:
                if j>=len(ndata):
                    for k in range(j-len(ndata)+1):
                        ndata.append(None)
                ndata[j] = self.data[i]

        del self.data[:]
        for i in range(len(ndata)):
            self.data.append(ndata[i])
        self.resize(self.width,hfate)
        return True

    def insertOrDeleteColumns(self,fate,wfate):
        if wfate==self.width and wfate==len(fate):
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
                at = fate[j]
                if at>=len(nrow):
                    for k in range(at-len(nrow)+1):
                        nrow.append(None)
                nrow[at] = row[j]
            while len(nrow)<wfate:
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
                v1 = "" + str(self.getCell(c,r))
                v2 = "" + str(alt.getCell(c,r))
                if (v1!=v2):
                    print("MISMATCH "+ v1 + " " + v2);
                    return False
        return True

    def clone(self):
        result = PythonTableView([])
        result.resize(self.get_width(), self.get_height())
        for c in range(self.width):
            for r in range(self.height):
                result.setCell(c,r,self.getCell(c,r))
        return result

    def create(self):
        return PythonTableView([])

    def getMeta(self):
        return None
