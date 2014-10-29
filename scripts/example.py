import daff
import sys

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

table1 = daff.PythonTableView(data1)
table2 = daff.PythonTableView(data2)

alignment = daff.Coopy.compareTables(table1,table2).align()

data_diff = []
table_diff = daff.PythonTableView(data_diff)

flags = daff.CompareFlags()
highlighter = daff.TableDiff(alignment,flags)
highlighter.hilite(table_diff)

diff2html = daff.DiffRender()
diff2html.usePrettyArrows(False)
diff2html.render(table_diff)
table_diff_html = diff2html.html()

sys.stdout.write(table_diff_html)
