
# This is not so much a Makefile as a collection of scripts.
# If you are just interested in Javascript only the js
# and test targets are important.

default: test

js:
	@echo "#######################################################"
	@echo "## Install dependencies"
	yes | haxelib install language/js.hxml
	@echo "#######################################################"
	@echo "## Set up directories"
	mkdir -p bin
	mkdir -p lib
	@echo "#######################################################"
	@echo "## Generate javascript"
	haxe language/js.hxml # produces lib/daff.js
	@echo "#######################################################"
	@echo "## Make library version"
	cat env/js/fix_exports.js >> lib/daff.js
	cat env/js/table_view.js >> lib/daff.js
	cat env/js/ndjson_table_view.js >> lib/daff.js
	cat env/js/sqlite_database.js >> lib/daff.js
	cat env/js/util.js >> lib/daff.js
	@echo "#######################################################"
	@echo "## Make executable version (just add shebang)"
	echo "#!/usr/bin/env node" > bin/daff.js
	cat lib/daff.js >> bin/daff.js
	chmod u+x bin/daff.js
	@echo "#######################################################"
	@echo "## Check size"
	@wc bin/daff.js

# The following 5 lines are the Makefile syntax for writing:
#
# for file in `ls -1 test/*.js`; do
#   node $file
# done
#
# in a way in which each invocation of node $file is a separate
# rule (unlike the old run_test in which all the $files are
# in the same rule)
js_test_files=$(wildcard test/*.js)
js_targets=$(subst .js,_js,$(js_test_files))
test: js $(js_targets)
test/%_js: test/%.js
	@cd test; echo == $*.js; NODE_PATH=$(PWD)/lib:$(PWD)/scripts node $*.js

min: js
	uglifyjs lib/daff.js > lib/daff.min.js
	gzip -k -f lib/daff.min.js
	@wc lib/daff.js
	@wc lib/daff.min.js
	@wc lib/daff.min.js.gz

cpp:
	haxe language/cpp.hxml

version:
	grep "\"version\"" package.json | grep -E -o "[.0-9]+" > version.txt
	cat coopy/Coopy.hx | sed "s/VERSION = .*;/VERSION = \"`cat version.txt`\";/" > coopy/Coopy.hx.next
	cmp coopy/Coopy.hx.next coopy/Coopy.hx || cp coopy/Coopy.hx.next coopy/Coopy.hx
	rm -f coopy/Coopy.hx.next version.txt
	@grep "\"version\"" package.json
	@grep "var VERSION" coopy/Coopy.hx

tag:
	# yes I know about npm-version
	@make version
	@make test
	@grep "\"version\"" package.json | grep -E -o "[.0-9]+" | tee version.txt
	@echo "git commit -m \"`cat version.txt`\" -a"
	@echo "git tag -a \"v`cat version.txt`\" -m \"`cat version.txt`\""
	read x
	git tag -d "v`cat version.txt`" || echo ok
	git commit -m "`cat version.txt`" -a && git tag -a "v`cat version.txt`" -m "`cat version.txt`"

doc:
	haxe -xml doc.xml language/js.hxml
	haxedoc doc.xml -f coopy

cpp_package:
	haxe language/cpp_for_package.hxml

php:
	haxe language/php.hxml
	find php_bin/lib/coopy -iname "*View.*.php" -exec sed -i 's/function hashSet(/function hashSet(\&/' {} \;
	cp env/php/*.class.php php_bin/lib/coopy/
	cp scripts/example.php php_bin/
	@echo 'Output in php_bin, run "php php_bin/index.php" for an example utility'
	@echo 'or try "php php_bin/example.php" for an example of using daff as a library'


java:
	rm -rf java_bin
	haxe -D no-compilation language/java.hxml
	cp scripts/JavaTableView.java java_bin/src/coopy
	cd java_bin && find src -iname "*.java" > cmd
	cp scripts/Example.java java_bin
	echo "Main-Class: coopy.Coopy" > java_bin/manifest
	cd java_bin && mkdir obj
	cd java_bin && javac -sourcepath src -d obj -g:none "@cmd"
	cd java_bin/obj && jar cvfm ../daff.jar ../manifest .
	cd java_bin && javac -cp daff.jar Example.java
	@echo 'Output in java_bin, run "java -jar java_bin/daff.jar" for help'
	@echo 'Run example with "java -cp java_bin/daff.jar:java_bin Example"'

cs:
	haxe language/cs.hxml
	@echo 'Output in cs_bin, do something like "gmcs -recurse:*.cs -main:coopy.Coopy -out:coopyhx.exe" in that directory'

py:
	rm -rf python_bin
	mkdir -p python_bin
	haxe language/py_util.hxml
	sed -i "1i#!/usr/bin/env python" python_bin/daff.py
	sed -i "s|.*Coopy.main.*||" python_bin/daff.py
	cat scripts/python_table_view.py >> python_bin/daff.py
	cat env/py/export_functions.py >> python_bin/daff.py
	cat env/py/sqlite_database.py >> python_bin/daff.py
	echo "if __name__ == '__main__':" >> python_bin/daff.py
	echo "\tCoopy.main()" >> python_bin/daff.py
	sed -i 's/Sys.stdout().writeString(txt)/get_stdout().write(txt.encode("utf-8", "strict"))/' python_bin/daff.py # fix utf-8
	sed -i 's/python_lib_Sys.stdout.buffer/get_stdout()/' python_bin/daff.py
	cp scripts/example.py python_bin/
	@echo 'Output in python_bin, run "python3 python_bin/daff.py" for an example utility'
	@echo 'or try "python3 python_bin/example.py" for an example of using daff as a library'

py2: py
	echo "Tweak python translation to work also on python2"
	echo "We need 3to2, https://bitbucket.org/amentajo/lib3to2"
	which 3to2
	3to2 -x except -x printfunction -x print -w python_bin/daff.py > /dev/null
	sed -i '14iimport codecs' python_bin/daff.py
	sed -i 's/.*stream.writable.*//' python_bin/daff.py
	sed -i 's/.*Read only stream.*//' python_bin/daff.py
	sed -i 's/python_lib_Builtin.open(path,.r.*)/codecs.open(path,"r","utf-8")/' python_bin/daff.py
	sed -i 's/python_lib_Builtin.open(path,.w.*)/codecs.open(path,"w","utf-8")/' python_bin/daff.py
	sed -i 's/= \([a-z0-9_.]*\)\.next()/= hxnext(\1)/' python_bin/daff.py
	sed -i 's/ unicode(/ hxunicode(/g' python_bin/daff.py
	sed -i 's/python_lib_Builtin.unicode/hxunicode/g' python_bin/daff.py
	sed -i 's/python_lib_Builtin.unichr/hxunichr/g' python_bin/daff.py
	sed -i 's/xrange/hxrange/g' python_bin/daff.py
	sed -i 's/python_lib_FuncTools.cmp_to_key/hx_cmp_to_key/g' python_bin/daff.py
	sed -i 's/^\([ \t]*\)def next(/\1def __next__(self): return self.next()\n\n\1def next(/g' python_bin/daff.py
	sed -i 's/from datetime import timezone/#from datetime import timezone/' python_bin/daff.py
	sed -i 's/Date.EPOCH_UTC =/#Date.EPOCH_UTC =/' python_bin/daff.py
	cp scripts/python23.py python_bin/daff2.py
	cat python_bin/daff.py | grep -v "from __future__" | grep -v "from __builtin__ import" | grep -v "import __builtin__ as" | grep -v '#!' >> python_bin/daff2.py
	mv python_bin/daff2.py python_bin/daff.py
	@echo 'tweaked python code to be python2 compatible'
	@echo 'try "python2 python_bin/example.py or daff.py"'

best_py:
	which 3to2 && make py2 || make py

rb:
	haxe language/rb.hxml || { echo "Ruby failed, do you have paulfitz/haxe?"; exit 1; }
	grep -v "Coopy.main" < ruby_bin/index.rb > ruby_bin/daff.rb
	echo "require_relative 'lib/coopy/table_view'" >> ruby_bin/daff.rb
	echo "Daff = Coopy" >> ruby_bin/daff.rb
	echo 'if __FILE__ == $$0' >> ruby_bin/daff.rb
	echo "\tCoopy::Coopy.main" >> ruby_bin/daff.rb
	echo "end" >> ruby_bin/daff.rb
	rm -f ruby_bin/index.rb
	chmod u+x ruby_bin/daff.rb
	cp env/rb/table_view.rb ruby_bin/lib/coopy
	cp scripts/example.rb ruby_bin/
	chmod u+x ruby_bin/example.rb

release: js test php py rb java
	echo "========================================================"
	echo "=== Setup"
	rm -rf release
	mkdir -p release
	echo "========================================================"
	echo "=== Javascript"
	cp bin/daff.js release
	echo "========================================================"
	echo "=== PHP"
	rm -rf daff_php
	mv php_bin daff_php
	rm -f daff_php.zip
	zip -r daff_php daff_php
	mv daff_php.zip release
	echo "========================================================"
	echo "=== Python"
	rm -rf daff_py
	mv python_bin daff_py
	rm -f daff_py.zip
	zip -r daff_py daff_py
	mv daff_py.zip release
	echo "========================================================"
	echo "=== Ruby"
	rm -rf daff_rb
	mv ruby_bin daff_rb
	rm -f daff_rb.zip
	zip -r daff_rb daff_rb
	mv daff_rb.zip release
	echo "========================================================"
	echo "=== Java"
	rm -rf daff_java
	mv java_bin daff_java
	rm -rf daff_java/obj
	rm -rf daff_java/hxjava_build.txt
	rm -rf daff_java/cmd
	rm -rf daff_java/manifest
	rm -f daff_java.zip
	zip -r daff_java daff_java
	mv daff_java.zip release
	echo "========================================================"
	echo "=== C++"
	rm -f /tmp/coopyhx_cpp/build/daff_cpp.zip
	rm -rf /tmp/coopyhx_cpp
	./packaging/cpp_recipe/build_cpp_package.sh /tmp/coopyhx_cpp
	cp /tmp/coopyhx_cpp/build/coopyhx_cpp.zip release/daff_cpp.zip

clean:
	rm -rf bin cpp_pack daff_php daff_py daff_rb release py_bin php_bin ruby_bin coopy.js coopy_node.js daff.js daff_java daff_util.js MANIFEST Gemfile python_bin daff.py lib daff *.gem

##############################################################################
##############################################################################
## 
## cross-target tests, with tests written in haxe
##

ntest: ntest_js ntest_rb ntest_py ntest_php ntest_java

ntest_js: js
	haxe -js ntest.js -D haxeJSON -main harness.Main
	NODE_PATH=$$PWD/lib node ntest.js

py_test_files=$(wildcard test/*.py)
py_targets=$(subst .py,_py,$(py_test_files))
ntest_py: py $(py_targets)
	rm -f daff/__init__.py daff.py
	haxe -python ntest.py -main harness.Main
	PYTHONPATH=$$PWD/python_bin python3 ntest.py
test/%_py: test/%.py
	@cd test; echo == $*.py; PYTHONPATH=${PYTHONPATH}:$(PWD)/python_bin python3 $*.py

ntest_py2: py2
	rm -f daff/__init__.py daff.py
	haxe -python ntest.py -main harness.Main
	PYTHONPATH=$$PWD/python_bin python3 ntest.py 

ntest_php:
	haxe -D haxeJSON -php ntest_php_dir -main harness.Main
	find ntest_php_dir/lib/coopy -iname "*View.*.php" -exec sed -i 's/function hashSet(/function hashSet(\&/' {} \;
	cp env/php/*.class.php ntest_php_dir/lib/coopy/
	#time hhvm ntest_php_dir/index.php
	time php5 ntest_php_dir/index.php
	#php5 -d xdebug.profiler_enable=1 -d xdebug.profiler_output_dir=/tmp ntest_php_dir/index.php

ntest_java:
	haxe -java ntest_java_dir -main harness.Main -D no-compilation
	cp scripts/JavaTableView.java ntest_java_dir/src/coopy
	#	echo "src/coopy/JavaTableView.java" >> ntest_java_dir/cmd
	cd ntest_java_dir && find src -iname "*.java" > cmd
	cd ntest_java_dir && mkdir -p obj
	cd ntest_java_dir && javac -sourcepath src -d obj -g:none "@cmd"
	java -cp ntest_java_dir/obj harness.Main

rb_test_files=$(wildcard test/*.rb)
rb_targets=$(subst .rb,_rb,$(rb_test_files))
ntest_rb: rb $(rb_tergets)
	haxe -rb ntestdotrb -main harness.Main
	cp env/rb/table_view.rb ntestdotrb/lib/coopy
	RUBYLIB=$$PWD/ntestdotrb ruby ntestdotrb/index.rb
test/%_rb: test/%.rb
	@cd test; echo == $*.rb; RUBYLIB=$(PWD)/ruby_bin:${RUBYLIB} ruby $*.rb

perf_js:
	haxe -D enbiggen -js ntest.js -main harness.Main
	NODE_PATH=$$PWD/lib node ntest.js

perf_php:
	haxe -D enbiggen -php ntest_php_dir -main harness.Main
	cp env/php/*.class.php ntest_php_dir/lib/coopy/
	#time hhvm ntest_php_dir/index.php
	time php5 ntest_php_dir/index.php

integration: js py
	./test/integration_git.sh js
	./test/integration_git.sh py3
	./test/integration_sqlite.sh js
	./test/integration_sqlite.sh py3

##############################################################################
##############################################################################
## 
## PYTHON PACKAGING
##

setup_py: best_py
	mkdir -p daff
	cp python_bin/daff.py daff/__init__.py
	echo "#!/usr/bin/env python" > daff.py
	cat python_bin/daff.py >> daff.py # wasteful but robust

sdist: setup_py
	rm -rf dist
	cp README.md README
	python3 setup.py sdist
	cd dist && mkdir tmp && cd tmp && tar xzvf ../daff*.tar.gz && cd daff-*[0-9] && ./setup.py build
	python3 setup.py sdist upload
	rm -rf dist/tmp


##############################################################################
##############################################################################
## 
## RUBY PACKAGING
##

rdist:
	make rb
	rm -rf lib bin
	mkdir -p lib
	cp ruby_bin/daff.rb lib
	cp -R ruby_bin/lib lib
	mkdir -p bin
	echo "#!/usr/bin/env ruby" > bin/daff.rb
	echo "require 'daff'" >> bin/daff.rb
	echo "Daff::Coopy.main" >> bin/daff.rb
	chmod u+x bin/daff.rb
	rm -f daff-*.gem
	gem build daff.gemspec

##############################################################################
##############################################################################
## 
## RELEASES
##

releases:
	@echo "Hey so you want to make a release?"
	@echo "And you've forgotten how?"
	@echo "Steps:"
	@echo "  make test && make ntest"
	@echo "  # Update version number in package.json"
	@echo "  make tag"
	@echo "  git push && git push --tags"
	@echo "  # move to a fresh checkout"
	@echo "  npm publish  # node"
	@echo "  make sdist   # pip"
	@echo "  make rdist   # gem"
	@echo "  gem push daff-.....gem"
	@echo "  make php"
	@echo "  # now, checkout daff-php at same level as daff"
	@echo "  # now, in daff-php"
	@echo "  ./fetch.sh"
	@echo "  git push && git push --tags"
