default: test

cpp:
	haxe compile_cpp.hxml

js:
	haxe compile_js.hxml # generates coopy.js
	cat coopy.js scripts/post_node.js > coopy_node.js
	mv coopy_node.js coopy.js

test: js
	./scripts/run_tests.sh
	@echo "=============================================================================="

doc:
	haxe -xml doc.xml compile_js.hxml
	haxedoc doc.xml -f coopy
	# 
	# result is in index.html and content directory
