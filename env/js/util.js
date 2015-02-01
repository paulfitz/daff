if (typeof exports != "undefined") {
    
    var tio = {};
    var tio_args = [];

    var coopy = exports;
    var fs = require('fs');
    var exec = require('child_process').exec;
    var readline = null;
    var Fiber = null;
    var sqlite3 = null;
    
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
	return tio_args;
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

    tio.openSqliteDatabase = function(path) {
	if (Fiber) {
	    return new SqliteDatabase(new sqlite3.Database(path),Fiber);
	}
	throw("run inside Fiber plz");
	return null;
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

    function run_daff_base(main,args) {
	tio_args = args.slice();
	var code = main.coopyhx(tio);
	if (code==999) {
	    if (cmd_pending!=null) {
		exec(cmd_pending,function(error,stdout,stderr) {
		    cmd_result = 0;
		    if (error!=null) {
			cmd_result = error.code;
		    }
		    return run_daff_base(main,args);
		});
	    }
	} 
	return code;
    }
    
    exports.run_daff_main = function() {
	var main = new exports.Coopy();
	var code = run_daff_base(main,process.argv.slice(2));
	if (code!=999) {
	    process.exit(code);
	}
    }

    exports.cmd = function(args) {
	var main = new exports.Coopy();
	var code = run_daff_base(main,args);
	return code;
    }
}

if (typeof require != "undefined") {
    if (require.main === module) {
	try {
	    exports.run_daff_main();
	} catch (e) {
	    if (e == "run inside Fiber plz") {
		try {
		    Fiber = require('fibers');
		    sqlite3 = require('sqlite3');
		} catch (err) {
		    // We don't have what we need for accessing the sqlite database.
		    console.log("No sqlite3/fibers");
		}
		Fiber(function() {
		    exports.run_daff_main();
		    console.log("ok");
		}).run();
	    }
	}
    }
}
