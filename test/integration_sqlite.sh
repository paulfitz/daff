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

{
    cat<<EOF
CREATE TABLE birds (id INTEGER PRIMARY KEY, name TEXT, count TEXT);
INSERT INTO birds VALUES(1,"robin","251");
INSERT INTO birds VALUES(2,"eagle","10");
INSERT INTO birds VALUES(3,"pigeon","140");

CREATE TABLE birds2 (id INTEGER PRIMARY KEY, name TEXT, count INTEGER, weather TEXT);
INSERT INTO birds2 VALUES(1,"robin",251,"warm");
INSERT INTO birds2 VALUES(2,"eagle",10,"");
INSERT INTO birds2 VALUES(3,"pigeon",140,"");
INSERT INTO birds2 VALUES(4,"penguin",5,"cold");
EOF
} | sqlite3 birds_v12.sqlite

{
    cat<<EOF
CREATE TABLE birds (id INTEGER, name TEXT, count TEXT);
INSERT INTO birds VALUES(1,"robin","251");
INSERT INTO birds VALUES(2,"eagle","10");
INSERT INTO birds VALUES(3,"pigeon","140");

CREATE TABLE birds2 (id INTEGER, name TEXT, count INTEGER, weather TEXT);
INSERT INTO birds2 VALUES(1,"robin",251,"warm");
INSERT INTO birds2 VALUES(2,"eagle",10,"");
INSERT INTO birds2 VALUES(3,"pigeon",140,"");
INSERT INTO birds2 VALUES(4,"penguin",5,"cold");
EOF
} | sqlite3 birds_v12_no_key.sqlite

function run_diff {
    v1="$1"
    v2="$2"
    ref_diff="$3"
    save_diff="$4"
    shift
    shift
    shift
    shift
    $DAFF_SCRIPT $v1 $v2 "$@" > $save_diff
    echo ""
    echo "$v1 -> $v2 ($save_diff)"
    $DAFF_SCRIPT $v1 $v2 "$@" # run separately to see color
    if [ -e $org/test/sqlite/${ref_diff} ]; then
        diff -w ${save_diff} $org/test/sqlite/${ref_diff} || {
            echo "${save_diff} not created correctly."
            exit 1
        } && {
            echo "${save_diff} created correctly."
        }
    else
        echo "${save_diff} has nothing to compare with."
    fi
}

run_diff v1.sqlite v2.sqlite basic.diff basic.diff
run_diff v1.sqlite v3.sqlite remove_table.diff remove_table.diff
run_diff v3.sqlite v1.sqlite add_table.diff add_table.diff
run_diff birds_v1.sqlite birds_v2.sqlite type_change.diff type_change.diff
run_diff $org/test/sqlite/blank.sqlite $org/test/sqlite/awkward.sqlite create_all.diff create_all.diff
if [ "$DAFF_LANGUAGE" = "js" ]; then
    # only have energy to tweak this on js for the moment
    run_diff $org/test/sqlite/blobby1.sqlite $org/test/sqlite/blobby2.sqlite with_blobs.diff with_blobs.diff
fi

run_diff birds_v12.sqlite birds_v12.sqlite type_change.diff type_change_v12.diff --table birds:birds2

run_diff birds_v12_no_key.sqlite birds_v12_no_key.sqlite type_change.diff \
  type_change_v12_no_key.diff --table birds:birds2 --id id
