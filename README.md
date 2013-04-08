coopyhx
=======

This library lets you compare tables, produce a summary of 
their differences, and use such a summary as a patch file.
It is written in Haxe, which compiles satisfactorily to Javascript
for in-browser use.  The library may also be compiled as C++.

For a live demo, see:
> http://paulfitz.github.com/coopyhx/

Get coopy.js here:
> http://paulfitz.github.com/coopyhx/coopy/coopy.js

This library is a stripped down version of the coopy toolbox (see
http://share.find.coop).  It is intended to compare tables that share
a common origin.  To compare tables from different origins, check out
the coopy toolbox.

The basics
----------

First, make sure you include `coopy.js`:
```html
<script src="coopy.js"></script>
```

Initially, you'll probably also want `jtable.js`.  This implements
a Javascript table wrapper with all the methods `coopyhx` will need for 
efficient manipulation of standard Javascript two-dimensional arrays.
```html
<script src="jtable.js"></script>
```

Here, then, is how to generate a description of the difference
between two example tables:
```js
var data1 = [['Country','Capital'],
    	     ['Ireland','Dublin'],
	     ['France','Paris'],
	     ['Spain','Barcelona']];
var data2 = [['Country','Capital'],
    	     ['Ireland','Dublin'],
	     ['France','Paris'],
	     ['Spain','Madrid'],
	     ['Germany','Berlin']];
var data_diff = [];

// wrap raw data in a standard way
var table1 = new coopy.JTable2(data1);
var table2 = new coopy.JTable2(data2);
var table_diff = new coopy.JTable2(data_diff);

// compute the alignment between rows and columns - the alignment
// object is handy for many purposes beyond producing diffs
var alignment = coopy.Coopy.compareTables(table1,table2).align();

// generate a diff in highlighter format
var flags = new coopy.CompareFlags();
var highlighter = new coopy.TableDiff(alignment,flags);
highlighter.hilite(table_diff);

console.log(data_diff);
```

For 3-way differences (that is, comparing two tables given knowledge
of a common ancestor) use `coopy.Coopy.compareTables3` (give ancestor
table as the first argument).

Here is how to apply that difference as a patch:
```js
var patcher = new coopy.HighlightPatch(table1,table_diff);
patcher.apply();
// table1 should now equal table2
```
