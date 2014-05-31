daff: data diff
===============

This is a library for comparing tables, producing a summary of their
differences, and using such a summary as a patch file.  It is
optimized for comparing tables that share a common origin, in other
words multiple versions of the "same" table.  It is written in Haxe,
translated to Javascript for in-browser use.  The library is also 
available as Haxe-generated Python3, PHP, or C++.  There are two
ruby translations.

For a live demo, see:
> http://paulfitz.github.com/daff/

Get the core library for your preferred language here:
> https://github.com/paulfitz/daff/releases

Or with node:
````sh
npm install daff
````

Or use the library to view csv diffs on github via a chrome extension:
> https://github.com/theodi/csvhub

The diff format used by `daff` is specified here:
> http://dataprotocols.org/tabular-diff-format/

This library is a stripped down version of the coopy toolbox (see
http://share.find.coop).  To compare tables from different origins, 
or with automatically generated IDs, or other complications, check out
the coopy toolbox.

The program
-----------

There is a commandline utility wrapping the core functions of the library:
````
$ daff
daff can produce and apply tabular diffs.
Call as:
  daff [--output OUTPUT.csv] a.csv b.csv
  daff [--output OUTPUT.csv] parent.csv a.csv b.csv
  daff [--output OUTPUT.jsonbook] a.jsonbook b.jsonbook
  daff patch [--output OUTPUT.csv] source.csv patch.csv
  daff trim [--output OUTPUT.csv] source.csv
  daff render [--output OUTPUT.html] diff.csv

If you need more control, here is the full list of flags:
  daff diff [--output OUTPUT.csv] [--context NUM] [--all] [--act ACT] a.csv b.csv
     --context NUM: show NUM rows of context
     --all:         do not prune unchanged rows
     --act ACT:     show only a certain kind of change (update, insert, delete)

  daff render [--output OUTPUT.html] [--css CSS.css] [--fragment] [--plain] diff.csv
     --css CSS.css: generate a suitable css file to go with the html
     --fragment:    generate just a html fragment rather than a page
     --plain:       do not use fancy utf8 characters to make arrows prettier
````

The library
-----------

The `daff` utility is a thin wrapper around a library called (through an accident of history) `coopyhx`.
To use this library from Javascript, first include `coopyhx.js` on a webpage:
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

For visualization, you may want to convert this to a HTML table
with appropriate classes on cells so you can color-code inserts,
deletes, updates, etc.  You can do this with:
```js
var diff2html = new coopy.DiffRender();
diff2html.render(table_diff);
var table_diff_html = diff2html.html();
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

Other languages
---------------

The `daff` library is written in [Haxe](http://haxe.org/), which
can be translated reasonably well into at least the following languages:

 * Javascript
 * PHP
 * Python
 * Java
 * C#
 * C++

The Javascript translation is available via npm. 
PHP and C++ translations are posted on the 
[Releases](https://github.com/paulfitz/daff/releases) page.
To make another translation, 
follow the 
[Haxe getting started tutorial](http://haxe.org/doc/start) for the
language you care about, then do one of:

```
make js
make php
make py
make java
make cs
make cpp
```

[@Floppy](https://github.com/Floppy) has made a lovingly-hand-written [native Ruby port](https://github.com/theodi/coopy-ruby) that covers core functionality.  I've made a brutally-machine-converted [Ruby port](https://github.com/paulfitz/coopy-ruby) that is a full translation but may include utter gibberish.

For each language, the `coopyhx` library expects to be handed an interface to tables you create, rather than creating them
itself.  This is to avoid inefficient copies from one format to another.  You'll find a `SimpleTable` class you can use if
you find this awkward.

Reading material
----------------

 * http://dataprotocols.org/tabular-diff-format/ : a specification of the diff format we use.
 * http://theodi.org/blog/csvhub-github-diffs-for-csv-files : using this library with github.
 * http://theodi.org/blog/adapting-git-simple-data : using this library with gitlab.
 * http://okfnlabs.org/blog/2013/08/08/diffing-and-patching-data.html : a summary of where the library came from.
 * http://blog.okfn.org/2013/07/02/git-and-github-for-data/ : a post about storing small data in git/github.
 * http://blog.ouseful.info/2013/08/27/diff-or-chop-github-csv-data-files-and-openrefine/ : counterpoint - a post discussing tracked-changes rather than diffs.

## License

Coopyhx is distributed under the MIT License.
