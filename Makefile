default: js cpp

cpp:
	haxe compile_cpp.hxml

js:
	haxe compile_js.hxml
	cat coopy.js test/coopy_ext.js > coopy_test.js
