// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class Native {

    static public function list(data: Dynamic) : Dynamic {
#if php
    // php makes a fuss
    untyped __php__("$ndata = array()");
    var w = data.length;
    if (w>0) {
        untyped __php__("$ndata = array_pad(array(),$w,null)");
        for (j in 0...w) {
            var x = data[j];
            untyped __php__("$ndata[$j] = $x");
        }
    }
    return untyped __php__("$ndata");
#elseif java
    // java makes a fuss
    var w = data.length;
    untyped __java__("Object[] ndata = new Object[w];");
    if (w>0) {
        for (j in 0...w) {
            var x = data[j];
            untyped __java__("ndata[j] = x");
        }
    }
    return untyped __java__("ndata");
#else
    return data;
#end
    }

    static public function nativeArray(data: Dynamic) : Dynamic {
#if php
    // php makes a fuss
    untyped __php__("$ndata = array()");
    var h = data.length;
    if (h>0) {
        var w = data[0].length;
        untyped __php__("$ndata = array_pad(array(),$h,array_pad(array(),$w,null))");
        for (i in 0...h) {
            for (j in 0...w) {
                var x = data[i][j];
                untyped __php__("$ndata[$i][$j] = $x");
            }
        }
    }
    return untyped __php__("$ndata");
#elseif java
    // java makes a fuss
    var h = data.length;
    untyped __java__("Object[][] ndata = new Object[h][];");
    if (h>0) {
        var w = data[0].length;
        for (i in 0...h) {
            var row = data[i];
            untyped __java__("Object[] nrow = new Object[w];");
            for (j in 0...w) {
                var x = row[j];
                untyped __java__("nrow[j] = x");
            }
            untyped __java__("ndata[i] = nrow");
        }
    }
    return untyped __java__("ndata");
#else
    return data;
#end
    }

    static public function table(data: Dynamic) : coopy.Table {
        data = nativeArray(data);
#if js
        untyped __js__("if (typeof daff == 'undefined') { globalThis.daff = require('daff'); }");
        return untyped __js__("new daff.TableView(data)");
#elseif python
        python.Syntax.pythonCode("daff = __import__('daff')");
        return python.Syntax.pythonCode("daff.PythonTableView(data)");
#elseif rb
        untyped __rb__("require 'lib/coopy/table_view' unless defined?(::Coopy::TableView)");
        return untyped __js__("::Coopy::TableView.new(data)");
#elseif php
        return untyped __php__("new \\coopy\\PhpTableView($data)");
#elseif java
        return untyped __java__("new coopy.JavaTableView((Object[][])data)");
#else
        return null;
#end
    }

    static public function isList(v: Dynamic) : Bool {
#if php
        untyped __php__("$keys = array_keys($v)");
        return untyped __php__("array_keys($keys) === $keys");
#else
        return true;
#end
    }

    static public function row(v: Dynamic, r: Int) : Dynamic {
#if java
        return untyped __java__("((Object[][])v)[r]");
#else
        return v[r];
#end
    }

    static public function exit(v: Int) {
#if js
       untyped __js__("process.exit(v)");
#else
       Sys.exit(v);
#end
    }

    static public function getHashKey(h: Dynamic, k: String) : Dynamic {
#if php
    return untyped __php__("$h[$k]");
#elseif js
    return untyped __js__("h[k]");
#elseif rb
    return untyped __rb__("h[k]");
#elseif python
    return untyped python.Syntax.pythonCode("h[k]");
#elseif java
    return h.get(k);
#else
    return Reflect.field(h,k);
#end
    }

    static public function wrap(callback : Dynamic) : Bool {
#if js
    untyped __js__("if (typeof Fiber == 'undefined') { globalThis.Fiber = require('fibers'); }");
    untyped __js__("if (typeof sqlite3 == 'undefined') { globalThis.sqlite3 = require('sqlite3'); }");
    untyped __js__("Fiber(function() { callback.body(); }).run();");
    return true;
#end
    return false;
    }

    static public function hasSqlite() : Bool {
#if js
    return true;
#end
#if python
    return true;
#end
    return false;
    }

    static public function openSqlite(name: String) : coopy.SqlDatabase {
#if js
        untyped __js__("if (typeof daff == 'undefined') { globalThis.daff = require('daff'); }");
    return untyped __js__("new daff.SqliteDatabase(new sqlite3.Database(name),name,Fiber)");
#elseif python
    python.Syntax.pythonCode("daff = __import__('daff')");
    return python.Syntax.pythonCode("daff.SqliteDatabase(name,name)");
#end
    return null;
    }
}

