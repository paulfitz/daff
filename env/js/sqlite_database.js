    (function() {

	SqliteDatabase = function(db,fname,Fiber) {
	    this.db = db;
            this.fname = fname;
	    this.row = null;
	    this.active = false;
	    this.index2name = {};
	    this.Fiber = Fiber;
            // quoting rule for CSV is compatible with Sqlite
            this.quoter = new daff.Csv();
            this.view = new daff.SimpleView();
	}

        SqliteDatabase.prototype.getHelper = function() {
            return new daff.SqliteHelper();
        }
	
	SqliteDatabase.prototype.getQuotedColumnName = function (name) {
	    return this.quoter.renderCell(this.view, name, true);
	}
	
	SqliteDatabase.prototype.getQuotedTableName = function (name) {
	    return this.quoter.renderCell(this.view, name.toString(), true);
	}
	
	SqliteDatabase.prototype.getColumns = function(name) {
	    var fiber = this.Fiber.current;
	    var qname = this.getQuotedColumnName(name);
	    var self = this;
	    this.db.all("pragma table_info("+qname+")", function(err,rows) {
		var lst = [];
		for (var i in rows) {
		    var x = rows[i];
                    var col = new daff.SqlColumn();
                    col.setName(x['name']);
                    col.setPrimaryKey(x['pk']>0);
                    if (x['type']) {
                        col.setType(x['type'],'sqlite');
                    }
		    lst.push(col);
		    self.index2name[i] = x['name'];
		}
		fiber.run(lst);
	    });
	    return this.Fiber.yield();
	}
	
	SqliteDatabase.prototype.exec = function(query,args) {
	    var fiber = this.Fiber.current;
	    if (args==null) {
		this.db.run(query,function(err) {
		    if (err) console.log(err);
		    fiber.run(err==null);
		});
		return this.Fiber.yield();
	    }
	    var statement = this.db.run(query,args,function(err) {
		if (err) console.log(err);
		fiber.run(err==null);
	    });
	    return this.Fiber.yield();
	}
	
	SqliteDatabase.prototype.beginRow = function(tab,row,order) {
	    return this.begin("SELECT * FROM " + this.getQuotedColumnName(tab) + " WHERE rowid = ?",
			      [row],
			      order);
	}
	
	SqliteDatabase.prototype.begin = function(query,args,order) {
	    if (order!=null) {
		this.index2name = {};
		var len = order.length;
		for (var i=0; i<len; i++) {
		    this.index2name[i] = order[i];
		}
	    }
	    var fiber = this.Fiber.current;
	    this.active = true;
	    var self = this;
	    this.db.each(query,(args==null)?[]:args,function(err,row) {
                var keys = Object.keys(row);
                for (var i=0; i<keys.length; i++) {
                    var val = row[keys[i]];
                    // cannot do much with blobs - replace them with a short hash.
                    if (Buffer.isBuffer(val)) {
                        var crypto = require('crypto');
                        var hash = crypto.createHash('md5').update(val).digest('hex');
                        row[keys[i]] = '[buffer:' + hash + ']';
                    }
                }
		if (err) {
		    fiber.run([false,0]);
		} else {
		    fiber.run([true,row]);
		}
	    },function(err,n) {
                if (err) {
                    console.log(err);
                }
		fiber.run([false,n]);
	    });
	    return true;
	}

	SqliteDatabase.prototype.read = function() {
	    if (!this.active) return false;
	    var v = this.Fiber.yield();
	    if (v[0]) {
		this.row = v[1];
		return true;
	    }
	    this.row = null;
	    this.active = false;
	    return false;
	}

	SqliteDatabase.prototype.get = function(index) {
	    return this.row[this.index2name[index]];
	}

	SqliteDatabase.prototype.end = function() {
	    while (this.active) {
		this.read();
	    }
	}

	SqliteDatabase.prototype.rowid = function() {
	    return "rowid";
	}

	SqliteDatabase.prototype.getNameForAttachment = function() {
	    return this.fname;
	}

        if (typeof exports !== 'undefined') {
            exports.SqliteDatabase = SqliteDatabase;
        }

    })();
