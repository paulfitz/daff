if (typeof require != "undefined") {
    if (require.main === module) {

	var coopy = exports;
	var fs = require('fs');
	var exec = require('child_process').exec;
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
	
	tio.async = function() {
	    return true;
	}

	tio.exists = function(path) {
	    return fs.existsSync(path);
	}

	var cmd_result = 1;
	var cmd_pending = null;

	tio.command = function(cmd,args) {
	    // we promise not to use any arguments with quotes in them
	    for (var i=0; i<args.length; i++) {
		var argi = args[i];
		if (argi.indexOf(" ")>=0) {
		    argi = "\"" + argi + "\"";
		}
		cmd += " " + argi;
	    }
	    var cmd = cmd; + " " + args.join(" ");
	    if (cmd == cmd_pending) {
		cmd_pending = null;
		return cmd_result;
	    } else if (cmd_pending!=null) {
		return 998; // "hack not working correctly"
	    }
	    cmd_pending = cmd;
	    return 999; // "cannot be executed synchronously"
	}

	var main = new coopy.Coopy();

	function run_daff() {
	    var code = main.coopyhx(tio);
	    if (code==999) {
		if (cmd_pending!=null) {
		    exec(cmd_pending,function(error,stdout,stderr) {
			cmd_result = 0;
			if (error!=null) {
			    cmd_result = error.code;
			}
			run_daff();
		    });
		}
	    } else {
		process.exit(code);
	    }
	}
	run_daff();
    }
}
