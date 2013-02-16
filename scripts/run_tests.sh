#!/bin/bash

for f in `cd test; ls $1*.js`; do
    echo "=============================================================================="
    echo "== $f"
    NODE_PATH=$PWD:$PWD/scripts nodejs --prof ./test/$f || exit 1
done
