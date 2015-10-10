#!/bin/bash

set -e

source scripts/language_environment.sh "$@"

which sqlite3
which diff

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


{
    cat<<EOF
CREATE TABLE birds (id INTEGER PRIMARY KEY, name TEXT, count TEXT);
INSERT INTO birds VALUES(1,"robin","251");
INSERT INTO birds VALUES(2,"eagle","10");
INSERT INTO birds VALUES(3,"pigeon","140");
EOF
} | sqlite3 birds_v1.sqlite

{
    cat<<EOF
CREATE TABLE birds (id INTEGER PRIMARY KEY, name TEXT, count INTEGER, weather TEXT);
INSERT INTO birds VALUES(1,"robin",251,"warm");
INSERT INTO birds VALUES(2,"eagle",10,"");
INSERT INTO birds VALUES(3,"pigeon",140,"");
INSERT INTO birds VALUES(4,"penguin",5,"cold");
EOF
} | sqlite3 birds_v2.sqlite



$DAFF_SCRIPT v1.sqlite v2.sqlite | tee basic.diff
$DAFF_SCRIPT v1.sqlite v2.sqlite
$DAFF_SCRIPT v1.sqlite v3.sqlite | tee remove_table.diff
$DAFF_SCRIPT v3.sqlite v1.sqlite | tee add_table.diff
$DAFF_SCRIPT birds_v1.sqlite birds_v2.sqlite

for diff in basic.diff add_table.diff remove_table.diff; do
    diff -w ${diff} $org/test/sqlite/${diff} || {
        echo "${diff} not created correctly."
        exit 1
    }
done
