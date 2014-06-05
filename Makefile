default: test

cpp:
	haxe language/cpp.hxml

js:
	haxe language/js.hxml # generates coopy.js
	cat coopy.js scripts/post_node.js > coopy_node.js
	sed 's/window != "undefined" ? window : exports/exports != "undefined" ? exports : window/' coopy_node.js > coopy.js  # better order for browserify
	cat coopy.js scripts/coopy_view.js > coopyhx.js
	@wc coopyhx.js

min: js
	uglifyjs coopyhx.js > coopyhx.min.js
	gzip -k -f coopyhx.min.js
	@wc coopyhx.js
	@wc coopyhx.min.js
	@wc coopyhx.min.js.gz

test: js
	./scripts/run_tests.sh
	@echo "=============================================================================="

csv2html: js
	./scripts/assemble_csv2html.sh

doc:
	haxe -xml doc.xml language/js.hxml
	haxedoc doc.xml -f coopy
	# 
	# result is in index.html and content directory


cpp_package:
	haxe language/cpp_for_package.hxml

php:
	haxe language/php.hxml
	cp scripts/PhpTableView.class.php php_bin/lib/coopy/
	cp scripts/example.php php_bin/
	@echo 'Output in php_bin, run "php php_bin/index.php" for an example utility'
	@echo 'or try "php php_bin/example.php" for an example of using coopyhx as a library'


java:
	haxe language/java.hxml
	@echo 'Output in java_bin, run "java -jar java_bin/java_bin.jar" for help'

cs:
	haxe language/cs.hxml
	@echo 'Output in cs_bin, do something like "gmcs -recurse:*.cs -main:coopy.Coopy -out:coopyhx.exe" in that directory'

py:
	mkdir -p py_bin
	haxe language/py.hxml
	haxe language/py_util.hxml
	cp scripts/python_table_view.py python_bin/
	cp scripts/example.py python_bin/
	@echo 'Output in python_bin, run "python3 python_bin/daff.py" for an example utility'
	@echo 'or try "python3 python_bin/example.py" for an example of using coopyhx as a library'

setup_py: py
	echo "#!/usr/bin/env python" > daff.py
	cat python_bin/daff.py | sed "s|.*Coopy.main.*||" >> daff.py
	cat python_bin/python_table_view.py | sed "s|import coopyhx as daff||" | sed "s|daff[.]||g" >> daff.py
	echo "if __name__ == '__main__':" >> daff.py
	echo "\tCoopy.main()" >> daff.py

release: js test php py
	rm -rf release
	mkdir -p release
	cp coopyhx.js release
	rm -rf coopyhx_php
	mv php_bin coopyhx_php
	rm -f coopyhx_php.zip
	zip -r coopyhx_php coopyhx_php
	mv coopyhx_php.zip release
	rm -rf coopyhx_py
	mv python_bin coopyhx_py
	rm -f coopyhx_py.zip
	zip -r coopyhx_py coopyhx_py
	mv coopyhx_py.zip release
	rm -f /tmp/coopyhx_cpp/build/coopyhx_cpp.zip
	rm -rf /tmp/coopyhx_cpp
	./packaging/cpp_recipe/build_cpp_package.sh /tmp/coopyhx_cpp
	cp /tmp/coopyhx_cpp/build/coopyhx_cpp.zip release

clean:
	rm -rf bin cpp_pack coopyhx_php coopyhx_py release py_bin php_bin
