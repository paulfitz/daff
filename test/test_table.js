var coopy = require('daff');
var assert = require('assert');

var table_classes = [coopy.SimpleTable, coopy.TableView];

for (var t=0; t<table_classes.length; t++) {
    var TableClass = table_classes[t];
    var table = new TableClass(5,10);

    assert.equal(table.get_width(),5);
    assert.equal(table.get_height(),10);
    
    table.setCell(2,3,42);
    table.setCell(2,2,14);
    assert.equal(table.getCell(2,3),42);
    assert.equal(table.getCell(2,2),14);
    
    var small_table = new TableClass(3,2);
    small_table.setCell(1,0,20);
    small_table.setCell(2,0,30);
    small_table.setCell(0,1,40);
    small_table.setCell(1,1,50);
    small_table.setCell(2,1,60);
    var txt = small_table.toString();
    assert.equal(txt,"null,20,30\n40,50,60\n");
}
