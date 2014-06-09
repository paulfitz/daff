if (typeof require != "undefined") {
    if (require.main === module) {

	var coopy = exports;
	var fs = require('fs');
	var readline = null;
	
	var tio = {}
	
	tio.getContent = function(name) {
	    if (name=="-") {
		// only works on Linux, all other solutions seem broken
		return fs.readFileSync('/dev/stdin',"utf8");
	    }
	    return fs.readFileSync(name,"utf8");
	}
	
	tio.saveContent = function(name,txt) {
	    return fs.writeFileSync(name,txt,"utf8");
	}
	
	tio.args = function() {
	    return process.argv.slice(2);
	}
	
	tio.writeStdout = function(txt) {
	    process.stdout.write(txt);
	}
	
	tio.writeStderr = function(txt) {
	    process.stderr.write(txt);
	}
	
	return coopy.coopyhx(tio);
    }
}
