coopyhx
=======

This is a library for comparing tables, producing a summary of their
differences, and using such a summary as a patch file.  It is
optimized for comparing tables that share a common origin, in other
words multiple versions of the "same" table.  It is written in Haxe,
translated to Javascript for in-browser use.  The library may also be
compiled as C++.

For a live demo, see:
> http://paulfitz.github.com/coopyhx/

Get the core library here:
> http://paulfitz.github.com/coopyhx/coopy/coopy.js

To apply the library to regular javascript 2D arrays, you'll also want:
> http://paulfitz.github.com/coopyhx/coopy/scripts/coopy_view.js

This library is a stripped down version of the coopy toolbox (see
http://share.find.coop).  To compare tables from different origins, 
or with automatically generated IDs, or other complications, check out
the coopy toolbox.

The basics
----------

First, include `coopy.js` for the basic library
and `coopy_view.js` to use that library with regular 2D arrays:
```html
<script src="coopy.js"></script>
<script src="coopy_view.js"></script>
```

For concreteness, assume we have two versions of a table,
`data1` and `data2`:
```js
var data1 = [
    ['Country','Capital'],
    ['Ireland','Dublin'],
    ['France','Paris'],
    ['Spain','Barcelona']
];
var data2 = [
    ['Country','Code','Capital'],
    ['Ireland','ie','Dublin'],
    ['France','fr','Paris'],
    ['Spain','es','Madrid'],
    ['Germany','de','Berlin']
];
```

To make those tables accessible to the library, we wrap them
in `coopy.CoopyTableView`:
```js
var table1 = new coopy.CoopyTableView(data1);
var table2 = new coopy.CoopyTableView(data2);
```

We can now compute the alignment between the rows and columns
in the two tables:
```js
var alignment = coopy.Coopy.compareTables(table1,table2).align();
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
var table_diff = new coopy.CoopyTableView(data_diff);

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
