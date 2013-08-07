// prepended to all this will be coopy material

var fs = require('fs');
var htmlencode = require('node-html-encoder');
var Encoder = require('node-html-encoder').Encoder;
var encoder = new Encoder('entity');

var coopy = exports || window.coopy;
var render = coopy.diffRenderer;

var puts = function(x) {
    process.stdout.write(x);
}

puts("<!DOCTYPE html>\n");
puts("<head>\n");
puts("  <style>\n");
puts(prefix);
puts("  </style>\n");
puts("</head>\n");
puts("<body>\n");
puts("  <div class=\"highlighter\">\n");

var first = process.argv[2];
var txt = fs.readFileSync(first,"utf8");
var table = (new coopy.Csv()).parseTable(txt);

var instance = {};
instance.getDataAtCell = function(r,c) {
    return table[r][c];
}

var h = table.length;
var w = table[0].length;
var output = new coopy.SimpleTable(w,h);
var style = new coopy.SimpleTable(w,h);
for (var r=0; r<h; r++) {
    for (var c=0; c<w; c++) {
	var td = {};
	var val = render(instance,td,r,c,{},table[r][c],{});
	var name = td.className;
	output.setCell(c,r,val);
	style.setCell(c,r,name);
    }
}

process.stdout.write("      <table>\n");
for (var r=0; r<h; r++) {
    process.stdout.write("        <tr>");
    for (var c=0; c<w; c++) {
	var s = style.getCell(c,r);
	if (s) {
	    process.stdout.write("<td class=\"" + s + "\">");
	} else {
	    process.stdout.write("<td>");
	}
	var v = output.getCell(c,r);
	process.stdout.write(encoder.htmlEncode(v));
	process.stdout.write("</td>");
    }
    process.stdout.write("</tr>\n");
}
process.stdout.write("     </table>\n");
process.stdout.write("   </div>\n");
process.stdout.write("  </body>\n");
process.stdout.write("</html>\n");
