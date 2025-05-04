// -*- js-indent-level: 4 -*-
if (typeof exports !== 'undefined') {
    
    var tio = {};
    var tio_args = [];

    var coopy = exports;
    var fs = require('fs');
    var exec = require('child_process').exec;
    var readline = null;
    var tty = null;
    
    tio.valid = function() {
        return true;
    }

    tio.getContent = function(name) {
        var txt = "";
	if (name=="-") {
	    // only works on Linux, all other solutions seem broken
	    txt = fs.readFileSync('/dev/stdin',"utf8");
	} else {
	    txt = fs.readFileSync(name,"utf8");
        }
        if (txt.charCodeAt(0) === 0xFEFF) {
	    return txt.slice(1);
	}
        return txt;
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
    
    tio.hasAsync = function() {
	return true;
    }

    tio.exists = function(path) {
	return fs.existsSync(path);
    }

    tio.isTtyKnown = function() {
        return true;
    }

    tio.isTty = function() {
        if (typeof process.stdout.isTTY !== 'undefined') {
            if (process.stdout.isTTY) return true;
        } else {
            // fall back on tty api
            if (tty==null) tty = require('tty');
            if (tty.isatty(process.stdout.fd)) return true;
        }
        // There's a wrinkle when called from git.  Git may have started a pager that
        // respects color but which will not be detected as a terminal.  In this case,
        // it appears that git defines GIT_PAGER_IN_USE, so we watch out for that.
        if (process.env.GIT_PAGER_IN_USE == 'true') return true;
        return false;
    }

    tio.openSqliteDatabase = function(path) {
        return new coopy.SqliteDatabase(path);
    }

    tio.sendToBrowser = function(html) {
        var http = require("http");
	var shutdown = null;
        var server = http.createServer(function(request, response) {
            response.writeHead(200, 
                               {
                                   "Content-Type": "text/html; charset=UTF-8",
                                   "Connection": "close"
                               });
            response.write(html);
            response.end();
	    setTimeout(function() { shutdown(); }, 0);
        });
	var sockets = {}, nextSocketId = 0;
	server.on('connection', function (socket) {
	    var socketId = nextSocketId++;
	    sockets[socketId] = socket;
	    socket.on('close', function () {
		delete sockets[socketId];
	    });
	});
	shutdown = function() {
	    server.close();
	    for (var socketId in sockets) {
		sockets[socketId].destroy();
	    }
	};
        server.listen(0,null,null,function() {
            var target = "http://localhost:" + server.address().port;
            var exec = require('child_process').exec;
            var cmd = "xdg-open";
            switch (process.platform) {
            case 'darwin':
		cmd = 'open';
		break;
            case 'win32':
		cmd = 'start ""';
		break;
            }
            exec(cmd + ' "' + target + '"', function(error) { 
		if (error) {
                    console.error(error);
                    server.close();
		}
            });
	});
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
    
    daff.run_daff_main = function() {
	var main = new daff.Coopy();
	var code = run_daff_base(main,process.argv.slice(2));
	if (code!=999) {
            if (code!=0) {
	        process.exit(code);
            }
	}
    }

    daff.cmd = function(args) {
	var main = new daff.Coopy();
	var code = run_daff_base(main,args);
	return code;
    }
}

if (typeof require != "undefined") {
    if (require.main === module) {
	daff.run_daff_main();
    }
}
