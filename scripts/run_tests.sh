#!/bin/bash

BASE="$PWD"
cd test || exit 1
for f in `ls -1 *.js | grep "$1"`; do
    echo "=============================================================================="
    echo "== $f"
    NODE_PATH=$BASE/lib:$BASE/scripts node ./$f || exit 1
done
for f in `ls -1 *.py | grep "$1"`; do
    echo "=============================================================================="
    echo "== $f"
    PYTHONPATH=$PYTHONPATH:$BASE/python_bin python3 ./$f || exit 1
done
echo "=============================================================================="
