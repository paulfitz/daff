// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class Native {

    static public function table(data: Dynamic) : coopy.Table {
#if js
        untyped __js__("if (typeof daff == 'undefined') { GLOBAL.daff = require('daff'); }");
        return untyped __js__("new daff.TableView(data)");
#elseif python
        python.Syntax.pythonCode("daff = __import__('daff')");
        return python.Syntax.pythonCode("daff.PythonTableView(data)");
#elseif rb
        untyped __js__("require 'ruby_table_view' unless RubyTableView");
        return untyped __js__("RubyTableView.new(data)");
#else
        return null;
#end
    }
}