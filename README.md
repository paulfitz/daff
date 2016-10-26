[![Build Status](https://travis-ci.org/paulfitz/daff.svg?branch=master)](https://travis-ci.org/paulfitz/daff)
[![NPM version](https://badge.fury.io/js/daff.svg)](http://badge.fury.io/js/daff)
[![Gem Version](https://badge.fury.io/rb/daff.svg)](http://badge.fury.io/rb/daff)
[![PyPI version](https://badge.fury.io/py/daff.svg)](http://badge.fury.io/py/daff)
[![PHP version](https://badge.fury.io/ph/paulfitz%2Fdaff-php.svg)](http://badge.fury.io/ph/paulfitz%2Fdaff-php)
[![Bower version](https://badge.fury.io/bo/daff.svg)](http://badge.fury.io/bo/daff)
![Badge count](http://img.shields.io/:badges-7/7-33aa33.svg)

daff: data diff
===============

This is a library for comparing tables, producing a summary of their
differences, and using such a summary as a patch file.  It is
optimized for comparing tables that share a common origin, in other
words multiple versions of the "same" table.

For a live demo, see:
> http://paulfitz.github.com/daff/

Install the library for your favorite language:
````sh
npm install daff -g  # node/javascript
pip install daff     # python
gem install daff     # ruby
composer require paulfitz/daff-php  # php
install.packages('daff') # R wrapper by Edwin de Jonge
bower install daff   # web/javascript
````

Other translations are available here:
> https://github.com/paulfitz/daff/releases

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

You can run `daff`/`daff.py`/`daff.rb` as a utility program:
````
$ daff
daff can produce and apply tabular diffs.
Call as:
  daff [--output OUTPUT.csv] a.csv b.csv
  daff [--output OUTPUT.csv] parent.csv a.csv b.csv
  daff [--output OUTPUT.ndjson] a.ndjson b.ndjson
  daff patch [--inplace] [--output OUTPUT.csv] a.csv patch.csv
  daff merge [--inplace] [--output OUTPUT.csv] parent.csv a.csv b.csv
  daff trim [--output OUTPUT.csv] source.csv
  daff render [--output OUTPUT.html] diff.csv
  daff git
  daff version

The --inplace option to patch and merge will result in modification of a.csv.

If you need more control, here is the full list of flags:
  daff diff [--output OUTPUT.csv] [--context NUM] [--all] [--act ACT] a.csv b.csv
     --context NUM: show NUM rows of context
     --all:         do not prune unchanged rows
     --act ACT:     show only a certain kind of change (update, insert, delete)

  daff diff --git path old-file old-hex old-mode new-file new-hex new-mode
     --git:         process arguments provided by git to diff drivers

  daff render [--output OUTPUT.html] [--css CSS.css] [--fragment] [--plain] diff.csv
     --css CSS.css: generate a suitable css file to go with the html
     --fragment:    generate just a html fragment rather than a page
     --plain:       do not use fancy utf8 characters to make arrows prettier
````

Formats supported are CSV, TSV, and [ndjson](http://dataprotocols.org/ndjson/).

Using with git
--------------

Run `daff git csv` to install daff as a diff and merge handler
for `*.csv` files in your repository.  Run `daff git` for instructions
on doing this manually. Your CSV diffs and merges will get smarter,
since git will suddenly understand about rows and columns, not just lines:

![Example CSV diff](http://paulfitz.github.io/daff-doc/images/daff_vs_diff.png)

The library
-----------

You can use `daff` as a library from any supported language.  We take 
here the example of Javascript.  To use `daff` on a webpage,
first include `daff.js`:
```html
<script src="daff.js"></script>
```
Or if using node outside the browser:
```js
var daff = require('daff');
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
in `daff.TableView`:
```js
var table1 = new daff.TableView(data1);
var table2 = new daff.TableView(data2);
```

We can now compute the alignment between the rows and columns
in the two tables:
```js
var alignment = daff.compareTables(table1,table2).align();
```

To produce a diff from the alignment, we first need a table
for the output:
```js
var data_diff = [];
var table_diff = new daff.TableView(data_diff);
```

Using default options for the diff:
```js
var flags = new daff.CompareFlags();
var highlighter = new daff.TableDiff(alignment,flags);
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
var diff2html = new daff.DiffRender();
diff2html.render(table_diff);
var table_diff_html = diff2html.html();
```

For 3-way differences (that is, comparing two tables given knowledge
of a common ancestor) use `daff.compareTables3` (give ancestor
table as the first argument).

Here is how to apply that difference as a patch:
```js
var patcher = new daff.HighlightPatch(table1,table_diff);
patcher.apply();
// table1 should now equal table2
```

For other languages, you should find sample code in 
the packages on the [Releases](https://github.com/paulfitz/daff/releases) page.

Supported languages
-------------------

The `daff` library is written in [Haxe](http://haxe.org/), which
can be translated reasonably well into at least the following languages:

 * Javascript
 * Python
 * Java
 * C#
 * C++
 * Ruby (using an [unofficial haxe target](https://github.com/paulfitz/haxe) developed for `daff`) 
 * PHP

Some translations are done for you on the
[Releases](https://github.com/paulfitz/daff/releases) page.
To make another translation, or to compile from source
first follow the [Haxe getting started tutorial](http://haxe.org/doc/start) for the
language you care about.  At the time of writing, if you are on OSX, you should
install haxe using `brew install haxe --HEAD`.  Then do one of:

```
make js
make php
make py
make java
make cs
make cpp
```

For each language, the `daff` library expects to be handed an interface to tables you create, rather than creating them
itself.  This is to avoid inefficient copies from one format to another.  You'll find a `SimpleTable` class you can use if
you find this awkward.

Other possibilities:

 * There's a daff wrapper for R written by [Edwin de Jonge](https://github.com/edwindj), see https://github.com/edwindj/daff and http://cran.r-project.org/web/packages/daff
 * There's a hand-written ruby port by [James Smith](https://github.com/Floppy), see https://github.com/theodi/coopy-ruby

API documentation
-----------------

 * You can browse the `daff` classes at http://paulfitz.github.io/daff-doc/

Sponsors
--------

<img src="http://datacommons.coop/images/the_zen_of_venn.png" alt="the zen of venn" height="100">
The [Data Commons Co-op](http://datacommons.coop),  "perhaps the geekiest of all cooperative organizations on the planet," has given great moral support during the development of `daff`.
Donate a multiple of `42.42` in your currency to let them know you care: [http://datacommons.coop/donate/](http://datacommons.coop/donate/)

Reading material
----------------

 * http://dataprotocols.org/tabular-diff-format/ : a specification of the diff format we use.
 * http://theodi.org/blog/csvhub-github-diffs-for-csv-files : using this library with github.
 * https://github.com/ropensci/unconf/issues/19 : a thread about diffing data in which daff shows up in at least four guises (see if you can spot them all).
 * http://theodi.org/blog/adapting-git-simple-data : using this library with gitlab.
 * http://okfnlabs.org/blog/2013/08/08/diffing-and-patching-data.html : a summary of where the library came from.
 * http://blog.okfn.org/2013/07/02/git-and-github-for-data/ : a post about storing small data in git/github.
 * http://blog.ouseful.info/2013/08/27/diff-or-chop-github-csv-data-files-and-openrefine/ : counterpoint - a post discussing tracked-changes rather than diffs.
 * http://blog.byronjsmith.com/makefile-shortcuts.html : a tutorial on using `make` for data, with daff in the mix. "Since git considers changes on a per-line basis,
   looking at diffs of comma-delimited and tab-delimited files can get obnoxious. The program daff fixes this problem."

## License

daff is distributed under the MIT License.
