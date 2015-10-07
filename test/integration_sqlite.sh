#!/bin/bash

set -e

source scripts/language_environment.sh "$@"

which sqlite3

{
    cat<<EOF
CREATE TABLE t1 (id INTEGER PRIMARY KEY, name TEXT);
INSERT INTO t1 VALUES(1,"test");
CREATE TABLE t2 (id INTEGER PRIMARY KEY, count INTEGER, note TEXT);
INSERT INTO t2 VALUES(1,15,"hello");
INSERT INTO t2 VALUES(2,82,"world");
EOF
} | sqlite3 v1.sqlite

{
    cat<<EOF
CREATE TABLE t1 (id INTEGER PRIMARY KEY, name TEXT);
INSERT INTO t1 VALUES(1,"testy");
CREATE TABLE t2 (id INTEGER PRIMARY KEY, count INTEGER, note TEXT);
INSERT INTO t2 VALUES(1,15,"hello");
INSERT INTO t2 VALUES(3,64,"space");
EOF
} | sqlite3 v2.sqlite

{
    cat<<EOF
CREATE TABLE t2 (id INTEGER PRIMARY KEY, count INTEGER, note TEXT);
INSERT INTO t2 VALUES(1,15,"hello");
INSERT INTO t2 VALUES(2,82,"world");
INSERT INTO t2 VALUES(4,101,"news");
EOF
} | sqlite3 v3.sqlite

$DAFF_SCRIPT v1.sqlite v2.sqlite | tee log.txt
$DAFF_SCRIPT v1.sqlite v2.sqlite
$DAFF_SCRIPT v1.sqlite v3.sqlite

