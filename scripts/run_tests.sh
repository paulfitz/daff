#!/bin/bash

BASE="$PWD"
cd test || exit 1

EXT=js
if [[ ! "$2" = "" ]]; then
    EXT="$2"
fi

for f in `ls -1 *.$EXT | grep "$1"`; do
    echo "=============================================================================="
    echo "== $f"
    if [[ "$EXT" = "js" ]]; then
	NODE_PATH=$BASE/lib:$BASE/scripts node ./$f || exit 1
    elif [[ "$EXT" = "py" ]]; then
	PYTHONPATH=$PYTHONPATH:$BASE/python_bin python3 ./$f || exit 1
    elif [[ "$EXT" = "rb" ]]; then
	RUBYLIB=$BASE/ruby_bin:$RUBYLIB ruby ./$f || exit 1
    else
	echo "Do not know what to do with '$EXT' files"
	exit 1
    fi
done
