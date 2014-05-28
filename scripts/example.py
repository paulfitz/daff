import coopyhx
from python_table_view import coopy_PythonTableView

data1 = [
  ['Country','Capital'],
  ['Ireland','Dublin'],
  ['France','Paris'],
  ['Spain','Barcelona']
  ]

data2 = [
  ['Country','Code','Capital'],
  ['Ireland','ie','Dublin'],
  ['France','fr','Paris'],
  ['Spain','es','Madrid'],
  ['Germany','de','Berlin']
  ]

table1 = coopy_PythonTableView(data1)
table2 = coopy_PythonTableView(data2)


alignment = coopyhx.coopy_Coopy.compareTables(table1,table2).align()

data_diff = []
table_diff = coopy_PythonTableView(data_diff)

flags = coopyhx.coopy_CompareFlags()
highlighter = coopyhx.coopy_TableDiff(alignment,flags)
highlighter.hilite(table_diff)

diff2html = coopyhx.coopy_DiffRender()
diff2html.usePrettyArrows(False)
diff2html.render(table_diff)
table_diff_html = diff2html.html()
print(table_diff_html)


