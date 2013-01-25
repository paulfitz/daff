default: js cpp

cpp:
	haxe compile_cpp.hxml

# testing whether we can easily swap in an external javascript object
# for some internal interface
js:
	haxe compile_js.hxml
	echo "Store = Object;" > coopy2.js
	cat coopy.js >> coopy2.js
	mv coopy2.js coopy.js
