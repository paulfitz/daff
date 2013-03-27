default: test

cpp:
	haxe compile_cpp.hxml

js:
	haxe compile_js.hxml # generates coopy.js
	cat coopy.js scripts/post_node.js > coopy_node.js

test: js
	./scripts/run_tests.sh
	@echo "=============================================================================="

