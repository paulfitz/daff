/**
 *
 * Author: James Smith <james@floppy.org.uk>
 * License: MIT
 * Source: https://github.com/paulfitz/daff/issues/2
 *
 */

var fs = require('fs');
var coopy = require('daff');
var assert = require('assert');

var old_table = new coopy.TableView([["planetary_body","acceleration"],["Earth","9.80665"],["Moon","1.625"],["Sun","274.1"],["Venus","8.872"],["Mars","3.78"],["Jupiter","25.93"],["Io","1.789"],["Europa","1.314"],["Ganymede","1.426"],["Callisto","1.24"],["Saturn","11.19"],["Titan","1.3455"],["Uranus","9.01"],["Titania","0.379"],["Oberon","0.347"],["Neptune","11.28"],["Triton"," 0.779"],["Pluto"," 0.61"]]);

var new_table = new coopy.TableView([["planetary_body","aphelion","acceleration"],["Earth","152098232","9.80665"],["Moon",null,"1.625"],["Sun","0","274.1"],["Mercury","69816900","3.7"],["Venus","108939000","8.872"],["Mars","249209300","3.78"],["Jupiter","816520800","25.93"],["Io",null,"1.789"],["Europa",null,"1.314"],["Ganymede",null,"1.426"],["Callisto",null,"1.24"],["Saturn","1513325783","11.19"],["Titan",null,"1.3455"],["Uranus","3004419704","9.01"],["Titania",null,"0.379"],["Oberon",null,"0.347"],["Neptune","4553946490","11.28"],["Triton",null,"0.779"],["Pluto","7311000000","0.61"]]);

var alignment = coopy.compareTables(old_table,new_table).align();

var data_diff = [];      
var table_diff = new coopy.TableView(data_diff);

var flags = new coopy.CompareFlags();
var highlighter = new coopy.TableDiff(alignment,flags);
highlighter.hilite(table_diff);

var diff2html = new coopy.DiffRender();
diff2html.render(table_diff);
diff_html = diff2html.html();

assert(diff_html.indexOf("<td class=\"add\">7311000000</td>")>=0);

var arrow = String.fromCharCode(8594);
var space = String.fromCharCode(9251);
assert(diff_html.indexOf("<td class=\"modify\">" + space + "0.61" + arrow + "0.61</td>")>=0);

var cell = new coopy.CellInfo();
var view = new coopy.SimpleView();
coopy.DiffRender.examineCell(0,0,view,"0.61-> 0.61","","->","",cell);
assert(cell.pretty_value == ("0.61" + arrow + space + "0.61"));
coopy.DiffRender.examineCell(0,0,view," 0.61->0.61","","->","",cell);
assert(cell.pretty_value == (space + "0.61" + arrow + "0.61"));
coopy.DiffRender.examineCell(0,0,view," 0.61 ->0.61","","->","",cell);
assert(cell.pretty_value == (space + "0.61" + space + arrow + "0.61"));
coopy.DiffRender.examineCell(0,0,view," 0.61 -> 0.61","","->","",cell);
assert(cell.pretty_value == (" 0.61" + space + arrow + " 0.61"));
coopy.DiffRender.examineCell(0,0,view," 0.61  exactly  -> 0.61 exactly","","->","",cell);
assert(cell.pretty_value == (" 0.61 " + space + "exactly" + space + space + arrow + " 0.61 exactly"));

coopy.DiffRender.examineCell(0,0,view,"0.61!-> 0.61!->0.61 ","","!->","",cell);
assert(cell.pretty_value == ("0.61" + arrow + space + "0.61" + arrow + "0.61" + space));
