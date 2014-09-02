import coopy.JavaTableView;

class Example {
    public static void main(String[] args) {

	Object[][] data1 = {
	    {"Country","Capital"},
	    {"Ireland","Dublin"},
	    {"France","Paris"},
	    {"Spain","Barcelona"}
	};

	Object[][] data2 = {
	    {"Country","Code","Capital"},
	    {"Ireland","ie","Dublin"},
	    {"France","fr","Paris"},
	    {"Spain","es","Madrid"},
	    {"Germany","de","Berlin"}
	};

	JavaTableView table1 = new JavaTableView(data1);
	JavaTableView table2 = new JavaTableView(data2);
	coopy.Alignment alignment = coopy.Coopy.compareTables(table1,table2,null).align();
	JavaTableView table_diff = new JavaTableView();
	coopy.CompareFlags flags = new coopy.CompareFlags();
	coopy.TableDiff highlighter = new coopy.TableDiff(alignment,flags);
	highlighter.hilite(table_diff);

	coopy.DiffRender diff2html = new coopy.DiffRender();
	diff2html.usePrettyArrows(false);
	diff2html.render(table_diff);
	String table_diff_html = diff2html.html();
	System.out.print(table_diff_html);
    }
}
