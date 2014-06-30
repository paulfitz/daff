#!/bin/bash

BASE="$PWD"
cd test || exit 1
for f in `ls *$1*.js`; do
    echo "=============================================================================="
    echo "== $f"
    NODE_PATH=$BASE/lib:$BASE/scripts nodejs --prof ./$f || exit 1
done
echo "=============================================================================="
