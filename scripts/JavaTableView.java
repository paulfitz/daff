package coopy;

/**
 *
 * For other languages, I implemented a simple wrapper around the most
 * obvious 2D representation of a table, to avoid unnecessary copies.
 * In Java, the 2D representations aren't really so convenient to
 * use that this is worth doing, if we are modifying the list.
 * So this wrapper switches representation once we start making
 * structural modifications.
 *
 */
public class JavaTableView extends haxe.lang.HxObject implements coopy.Table
{
    private Object[][] basic_data;
    private coopy.SimpleTable edit_data;
    private int w;
    private int h;

    public JavaTableView() {
	basic_data = null;
	edit_data = new coopy.SimpleTable(1,1);
	w = h = 0;
    }
	
    public JavaTableView(Object[][] data) {
	basic_data = data;
	edit_data = null;
	h = basic_data.length;
	if (h>0) {
	    w = basic_data[0].length;
	} else {
	    w = 0;
	}
    }
	
    public int get_width() {
	if (edit_data!=null) return edit_data.get_width();
	return this.w;
    }	
	
    public int get_height() {
	if (edit_data!=null) return edit_data.get_height();
	return this.h;
    }

    private void needToEdit() {
	if (edit_data==null) {
	    edit_data = new coopy.SimpleTable(w,h);
	    for (int y=0; y<h; y++) {
		for (int x=0; x<w; x++) {
		    edit_data.setCell(x,y,basic_data[y][x]);
		}
	    }
	    w = 0;
	    h = 0;
	}
	basic_data = null;
    }

    public Object[][] getData() {
	if (basic_data == null) {
	    int ww = get_width();
	    int hh = get_height();
	    basic_data = new Object[hh][ww];
	    for (int y=0; y<h; y++) {
		for (int x=0; x<w; x++) {
		    basic_data[y][x] = edit_data.getCell(x,y);
		}
	    }
	}
	return basic_data;
    }

    public Object getCell(int x, int y) {
	if (edit_data!=null) return edit_data.getCell(x,y);
	return basic_data[y][x];
    }
	
    public void setCell(int x, int y, java.lang.Object c) {
	if (edit_data!=null) {
	    edit_data.setCell(x,y,c);
	    return;
	}
	basic_data[y][x] = c;
    }
		
    public coopy.View getCellView() {
	return new coopy.SimpleView();
    }
	
    public boolean isResizable() {
	return true;
    }
	
    public boolean resize(int w, int h) {
	needToEdit();
	return edit_data.resize(w,h);
    }
	
    public void clear() {
	Object[][] data = {};
	this.basic_data = data;
	this.edit_data = null;
    }
	
    public boolean insertOrDeleteRows(haxe.root.Array<java.lang.Object> fate, int hfate) {
	needToEdit();
	return edit_data.insertOrDeleteRows(fate,hfate);
    }
	
    public   boolean insertOrDeleteColumns(haxe.root.Array<java.lang.Object> fate, int wfate) {
	needToEdit();
	return edit_data.insertOrDeleteColumns(fate,wfate);
    }

    public boolean trimBlank() {
	needToEdit();
	return edit_data.trimBlank();
    }
    
    @Override public java.lang.String toString() {
	return coopy.SimpleTable.tableToString(this);
    }

    @Override public JavaTableView clone() {
	JavaTableView result = new JavaTableView();
	result.resize(w,h);
	for (int c=0; c<w; c++) {
	    for (int r=0; r<h; r++) {
		result.setCell(c,r,getCell(c,r));
	    }
	}
	return result;
    }

    @Override public JavaTableView create() {
	return new JavaTableView();
    }

    @Override public coopy.Meta getMeta() {
	return null;
    }

    /*
     *
     * The following methods shouldn't be needed since daff should
     * never need dynamic access to this class.  However, there's
     * a bug in haxe related to setters/getters that I need to chase.
     * So there are here for now.
     *
     */


    public coopy.Table getTable() {
	return this;
    }

    @Override public   double __hx_setField_f(java.lang.String field, double value, boolean handleProperties) {
	throw null;
    }

    @Override public Object __hx_setField(java.lang.String field, java.lang.Object value, boolean handleProperties) {
	throw null;
    }

    @Override public java.lang.Object __hx_getField(java.lang.String field, boolean throwErrors, boolean isCheck, boolean handleProperties) {
	boolean onwards = true;
	switch (field.hashCode()) {
	case -75605984:
	    if (field.equals("getData"))  {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ),  haxe.lang.Runtime.toString("getData"))) );
	    }
	    break;
	case -510954926:
	    if (field.equals("trimBlank")) {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ), haxe.lang.Runtime.toString("trimBlank"))) );
	    }
	    break;
	case 3076010:
	    if (field.equals("data")) {
		onwards = false;
		return this.getData();
	    }
	    break;
	case 1889278614:
	    if (field.equals("insertOrDeleteColumns")) {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ), haxe.lang.Runtime.toString("insertOrDeleteColumns"))) );
	    }
	    break;
	case 1186308544:
	    if (field.equals("insertOrDeleteRows")) {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ), haxe.lang.Runtime.toString("insertOrDeleteRows"))) );
	    }
	    break;
	case 94746189:
	    if (field.equals("clear")) {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ), haxe.lang.Runtime.toString("clear"))) );
	    }
	    break;
	case 1965941272:
	    if (field.equals("getTable")) {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ), haxe.lang.Runtime.toString("getTable"))) );
	    }
	    break;
	case -934437708:
	    if (field.equals("resize")) {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ), haxe.lang.Runtime.toString("resize"))) );
	    }
	    break;
	case -1221029593:
	    if (field.equals("height")) {
		onwards = false;
		return this.get_height();
	    }
	    break;
	case -972315487:
	    if (field.equals("isResizable")) {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ), haxe.lang.Runtime.toString("isResizable"))) );
	    }
	    break;
	case 113126854:
	    if (field.equals("width")) {
		onwards = false;
		return this.get_width();
	    }
	    break;
	case 1160377501:
	    if (field.equals("getCellView")) {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ), haxe.lang.Runtime.toString("getCellView"))) );
	    }
	    break;
	case -1776922004:
	    if (field.equals("toString")) {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ), haxe.lang.Runtime.toString("toString"))) );
	    }
	    break;
	case 1150076829:
	    if (field.equals("get_width")) {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ), haxe.lang.Runtime.toString("get_width"))) );
	    }
	    break;
	case 1984477412:
	    if (field.equals("setCell")) {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ), haxe.lang.Runtime.toString("setCell"))) );
	    }
	    break;
	case 859648560:
	    if (field.equals("get_height")) {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ), haxe.lang.Runtime.toString("get_height"))) );
	    }
	    break;
	case -75632168:
	    if (field.equals("getCell")) {
		onwards = false;
		return ((haxe.lang.Function) (new haxe.lang.Closure(((java.lang.Object) (this) ), haxe.lang.Runtime.toString("getCell"))) );
	    }
	    break;
	}

        // pending: add getMetaView here and in __hx_getField_f
			
	if (onwards) {
	    return super.__hx_getField(field, throwErrors, isCheck, handleProperties);
	}
	throw null;
    }

    @Override public double __hx_getField_f(java.lang.String field, boolean throwErrors, boolean handleProperties) {
	boolean onwards = true;
	switch (field.hashCode()) {
	case -1221029593:
	    if (field.equals("height")) {
		onwards = false;
		return (double)(this.get_height());
	    }
	    break;
	case 113126854:
	    if (field.equals("width")) {
		onwards = false;
		return (double)(this.get_width());
	    }
	    break;
	}
			
	if (onwards) {
	    return super.__hx_getField_f(field, throwErrors, handleProperties);
	}
	throw null;
    }
	

    @Override public java.lang.Object __hx_invokeField(java.lang.String field, java.lang.Object[] dynargs) {
	boolean onwards = true;
	switch (field.hashCode()) {
	case -75605984:
	    if (field.equals("getData")) {
		onwards = false;
		return this.getData();
	    }
	    break;
	case -510954926:
	    if (field.equals("trimBlank")) {
		onwards = false;
		return this.trimBlank();
	    }
	    break;
	case 1965941272:
	    if (field.equals("getTable"))  {
		onwards = false;
		return this.getTable();
	    }
	    break;
	case 1889278614:
	    if (field.equals("insertOrDeleteColumns")) {
		onwards = false;
		return this.insertOrDeleteColumns(((haxe.root.Array<java.lang.Object>) (dynargs[0]) ), ((int) (haxe.lang.Runtime.toInt(dynargs[1])) ));
	    }
	    break;
	case 1150076829:
	    if (field.equals("get_width")) {
		onwards = false;
		return this.get_width();
	    }
	    break;
	case 1186308544:
	    if (field.equals("insertOrDeleteRows")) {
		onwards = false;
		return this.insertOrDeleteRows(((haxe.root.Array<java.lang.Object>) (dynargs[0]) ), ((int) (haxe.lang.Runtime.toInt(dynargs[1])) ));
	    }
	    break;
	case 859648560:
	    if (field.equals("get_height")) {
		onwards = false;
		return this.get_height();
	    }
	    break;
	case 94746189:
	    if (field.equals("clear")) {
		onwards = false;
		this.clear();
	    }
	    break;
	case -934437708:
	    if (field.equals("resize")) {
		onwards = false;
		return this.resize(((int) (haxe.lang.Runtime.toInt(dynargs[0])) ), ((int) (haxe.lang.Runtime.toInt(dynargs[1])) ));
	    }
	    break;
	case -75632168:
	    if (field.equals("getCell")) {
		onwards = false;
		return this.getCell(((int) (haxe.lang.Runtime.toInt(dynargs[0])) ), ((int) (haxe.lang.Runtime.toInt(dynargs[1])) ));
	    }
	    break;
	case -972315487:
	    if (field.equals("isResizable")) {
		onwards = false;
		return this.isResizable();
	    }
	    break;
	case 1984477412:
	    if (field.equals("setCell")) {
		onwards = false;
		this.setCell(((int) (haxe.lang.Runtime.toInt(dynargs[0])) ), ((int) (haxe.lang.Runtime.toInt(dynargs[1])) ), dynargs[2]);
	    }
	    break;
	case 1160377501:
	    if (field.equals("getCellView")) {
		onwards = false;
		return this.getCellView();
	    }
	    break;
	case -1776922004:
	    if (field.equals("toString")) {
		onwards = false;
		return this.toString();
	    }
	    break;
	}
	
	if (onwards) {
	    return super.__hx_invokeField(field, dynargs);
	}		
	return null;
    }
	

    @Override public   void __hx_getFields(haxe.root.Array<java.lang.String> baseArr) {
	baseArr.push("width");
	baseArr.push("height");
	baseArr.push("data");
	super.__hx_getFields(baseArr);
    }
}

