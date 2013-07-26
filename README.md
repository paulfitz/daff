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

The diff is now in `table_diff`, in highlighter format, see
specification here:
> http://share.find.coop/doc/spec_hilite.html

For 3-way differences (that is, comparing two tables given knowledge
of a common ancestor) use `coopy.compareTables3` (give ancestor
table as the first argument).

Here is how to apply that difference as a patch:
```js
var patcher = new coopy.HighlightPatch(table1,table_diff);
patcher.apply();
// table1 should now equal table2
```

## License

(The MIT License)

Copyright (c) 2013 Paul Fitzpatrick &lt;paul@robotrebuilt.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

