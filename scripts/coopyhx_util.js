#!/usr/bin/env node

var coopy = require("coopyhx");
var fs =  require('fs');

var tio = {}

tio.getContent = function(name) {
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
