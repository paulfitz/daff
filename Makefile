default: js cpp

cpp:
	haxe compile_cpp.hxml

js:
	haxe compile_js.hxml
	cat coopy.js scripts/exports.js > coopy_test.js # add node exports
	sed -i "s|Coopy.main()|//Coopy.main()|" coopy_test.js
	mv coopy_test.js coopy.js

test: js
	./scripts/run_tests.sh
	@echo "=============================================================================="

