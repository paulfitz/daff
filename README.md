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
> http://paulfitz.github.com/coopyhx/coopy/coopyhx.js

Or with node:
````sh
npm install coopyhx
````

This library is a stripped down version of the coopy toolbox (see
http://share.find.coop).  To compare tables from different origins, 
or with automatically generated IDs, or other complications, check out
the coopy toolbox.

The basics
----------

First, include `coopyhx.js` on a webpage:
```html
<script src="coopyhx.js"></script>
```
Or with nodejs:
```js
var coopy = require('coopyhx');
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
var alignment = coopy.compareTables(table1,table2).align();
```

To produce a diff from the alignment, we first need a table
for the output:
```js
var data_diff = [];
var table_diff = new coopy.CoopyTableView(data_diff);
```

Using default options for the diff:
```js
var flags = new coopy.CompareFlags();
var highlighter = new coopy.TableDiff(alignment,flags);
highlighter.hilite(table_diff);
```

The diff is now in `data_diff` in highlighter format, see
specification here:
> http://share.find.coop/doc/spec_hilite.html

```js
[ [ '!', '', '+++', '' ],
  [ '@@', 'Country', 'Code', 'Capital' ],
  [ '+', 'Ireland', 'ie', 'Dublin' ],
  [ '+', 'France', 'fr', 'Paris' ],
  [ '->', 'Spain', 'es', 'Barcelona->Madrid' ],
  [ '+++', 'Germany', 'de', 'Berlin' ] ]
```

For 3-way differences (that is, comparing two tables given knowledge
of a common ancestor) use `coopy.compareTables3` (give ancestor
table as the first argument).

Here is how to apply that difference as a patch:
```js
var patcher = new coopy.HighlightPatch(table1,table_diff);
patcher.apply();
// table1 should now equal table2
```
