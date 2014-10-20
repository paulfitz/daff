// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class Native {

    static public function nativeArray(data: Dynamic) : Dynamic {
#if php
    // php makes a fuss
    untyped __php__("$ndata = array()");
    var h = data.length;
    if (h>0) {
        var w = data[0].length;
        for (i in 0...h) {
            var row = data[i];
            untyped __php__("$nrow = array()");
            for (j in 0...w) {
                var x = row[j];
                untyped __php__("array_push($nrow,$x)");
            }
            untyped __php__("array_push($ndata,$nrow)");
        }
    }
    return untyped __php__("$ndata");
#else
    return data;
#end
    }

    static public function table(data: Dynamic) : coopy.Table {
        data = nativeArray(data);
#if js
        untyped __js__("if (typeof daff == 'undefined') { GLOBAL.daff = require('daff'); }");
        return untyped __js__("new daff.TableView(data)");
#elseif python
        python.Syntax.pythonCode("daff = __import__('daff')");
        return python.Syntax.pythonCode("daff.PythonTableView(data)");
#elseif rb
        untyped __js__("require 'ruby_table_view' unless RubyTableView");
        return untyped __js__("RubyTableView.new(data)");
#elseif php
        return untyped __php__("new coopy_PhpTableView($data)");
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
}