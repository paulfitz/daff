// -*- js-indent-level: 4 -*-
(function() {
    const crypto = require('crypto');
    /* assume daff is available */

    let DatabaseConstructor;

    const SqliteDatabase = function(dbPath) {
        if (!DatabaseConstructor) {
            try {
                // Attempt to use built-in node:sqlite (Node.js v23+)
                // There's a warning in v23 which is annoying if daff
                // is used as a utility.
                process.removeAllListeners('warning').on('warning', err => {
                    if (err.name !== 'ExperimentalWarning' && !err.message.includes('experimental')) {
                        console.warn(err)
                    }
                });
                const { DatabaseSync } = require('node:sqlite');
                DatabaseConstructor = DatabaseSync;
            } catch (err) {
                try {
                    // Fallback to better-sqlite3
                    DatabaseConstructor = require('better-sqlite3');
                } catch (err) {
                    throw new Error("Problem: daff needs sqlite support for node.\nPlease use node v23 or later, or install better-sqlite3.");
                }
            }
        }
        this.db = new DatabaseConstructor(dbPath);
        this.fname = dbPath;
        this.row = null;
        this.active = false;
        this.index2name = {};
        // quoting rule for CSV is compatible with Sqlite
        this.quoter = new daff.Csv();
        this.view = new daff.SimpleView();
    };

    SqliteDatabase.prototype.getHelper = function() {
        return new daff.SqliteHelper();
    };

    SqliteDatabase.prototype.getQuotedColumnName = function(name) {
        return this.quoter.renderCell(this.view, name, true);
    };

    SqliteDatabase.prototype.getQuotedTableName = function(name) {
        return this.quoter.renderCell(this.view, name.toString(), true);
    };

    SqliteDatabase.prototype.getColumns = function(name) {
        const qname = this.getQuotedColumnName(name);
        const stmt = this.db.prepare(`PRAGMA table_info(${qname})`);
        const rows = stmt.all();
        const lst = [];
        for (let i = 0; i < rows.length; i++) {
            const x = rows[i];
            const col = new daff.SqlColumn();
            col.setName(x.name);
            col.setPrimaryKey(x.pk > 0);
            if (x.type) {
                col.setType(x.type, 'sqlite');
            }
            lst.push(col);
            this.index2name[i] = x.name;
        }
        return lst;
    };

    SqliteDatabase.prototype.exec = function(query, args) {
        try {
            if (args == null) {
                this.db.prepare(query).run();
            } else {
                this.db.prepare(query).run(...args);
            }
            return true;
        } catch (err) {
            console.log(err);
            return false;
        }
    };

    SqliteDatabase.prototype.beginRow = function(tab, row, order) {
        return this.begin(
            `SELECT * FROM ${this.getQuotedColumnName(tab)} WHERE rowid = ?`,
            [row],
            order
        );
    };

    SqliteDatabase.prototype.begin = function(query, args, order) {
        if (order != null) {
            this.index2name = {};
            const len = order.length;
            for (let i = 0; i < len; i++) {
                this.index2name[i] = order[i];
            }
        }
        this.active = true;
        const stmt = this.db.prepare(query);
        this.iterator = stmt.iterate(...(args || []))[Symbol.iterator]();
        return true;
    };

    SqliteDatabase.prototype.read = function() {
        if (!this.active) return false;
        const result = this.iterator.next();
        if (result.done) {
            this.row = null;
            this.active = false;
            return false;
        }
        const row = result.value;
        const keys = Object.keys(row);
        for (let i = 0; i < keys.length; i++) {
            const val = row[keys[i]];
            // cannot do much with blobs - replace them with a short hash.
            if (Buffer.isBuffer(val)) {
                const hash = crypto.createHash('md5').update(val).digest('hex');
                row[keys[i]] = '[buffer:' + hash + ']';
            }
        }
        this.row = row;
        return true;
    };

    SqliteDatabase.prototype.get = function(index) {
        return this.row[this.index2name[index]];
    };

    SqliteDatabase.prototype.end = function() {
        while (this.active) {
            this.read();
        }
    };

    SqliteDatabase.prototype.rowid = function() {
        return 'rowid';
    };

    SqliteDatabase.prototype.getNameForAttachment = function() {
        return this.fname;
    };

    if (typeof exports !== 'undefined') {
        exports.SqliteDatabase = SqliteDatabase;
    }
})();
