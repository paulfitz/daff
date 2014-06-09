default: test

cpp:
	haxe language/cpp.hxml

js:
	haxe language/js.hxml # generates coopy.js
	cat coopy.js scripts/post_node.js > coopy_node.js
	sed 's/window != "undefined" ? window : exports/exports != "undefined" ? exports : window/' coopy_node.js > coopy.js  # better order for browserify
	cat coopy.js scripts/table_view.js > daff.js
	@wc daff.js

min: js
	uglifyjs daff.js > daff.min.js
	gzip -k -f daff.min.js
	@wc daff.js
	@wc daff.min.js
	@wc daff.min.js.gz

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
	@echo 'or try "php php_bin/example.php" for an example of using daff as a library'


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
	@echo 'or try "python3 python_bin/example.py" for an example of using daff as a library'

rb:
	haxe language/rb.hxml || { echo "Ruby failed, do you have paulfitz/haxe?"; exit 1; }
	grep -v "Coopy.main" < ruby_bin/index.rb > ruby_bin/daff.rb
	echo "Daff = Coopy" >> ruby_bin/daff.rb
	echo 'if __FILE__ == $$0' >> ruby_bin/daff.rb
	echo "\tCoopy::Coopy.main" >> ruby_bin/daff.rb
	echo "end" >> ruby_bin/daff.rb
	rm -f ruby_bin/index.rb
	chmod u+x ruby_bin/daff.rb
	cp scripts/ruby_table_view.rb ruby_bin/
	cp scripts/example.rb ruby_bin/
	chmod u+x ruby_bin/example.rb

release: js test php py rb
	rm -rf release
	mkdir -p release
	cp daff.js release
	rm -rf coopyhx_php
	mv php_bin daff_php
	rm -f daff_php.zip
	zip -r daff_php daff_php
	mv daff_php.zip release
	rm -rf daff_py
	mv python_bin daff_py
	rm -f daff_py.zip
	zip -r daff_py daff_py
	mv daff_py.zip release
	rm -rf daff_rb
	mv ruby_bin daff_rb
	rm -f daff_rb.zip
	zip -r daff_rb daff_rb
	mv daff_rb.zip release
	rm -f /tmp/coopyhx_cpp/build/daff_cpp.zip
	rm -rf /tmp/coopyhx_cpp
	./packaging/cpp_recipe/build_cpp_package.sh /tmp/coopyhx_cpp
	cp /tmp/coopyhx_cpp/build/coopyhx_cpp.zip release/daff_cpp.zip

clean:
	rm -rf bin cpp_pack daff_php daff_py daff_rb release py_bin php_bin ruby_bin


##############################################################################
##############################################################################
## 
## PYTHON PACKAGING
##

setup_py: py
	echo "#!/usr/bin/env python" > daff.py
	cat python_bin/daff.py | sed "s|.*Coopy.main.*||" >> daff.py
	cat python_bin/python_table_view.py | sed "s|import coopyhx as daff||" | sed "s|daff[.]||g" >> daff.py
	echo "if __name__ == '__main__':" >> daff.py
	echo "\tCoopy.main()" >> daff.py
	mkdir -p daff
	cp daff.py daff/__init__.py

sdist: setup_py
	rm -rf dist
	mv page /tmp/sdist_does_not_like_page
	python3 setup.py sdist
	cd dist && mkdir tmp && cd tmp && tar xzvf ../daff*.tar.gz && cd daff-*[0-9] && ./setup.py build
	python3 setup.py sdist upload
	rm -rf dist/tmp
	mv /tmp/sdist_does_not_like_page page

