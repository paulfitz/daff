#!/bin/bash

for f in `cd test; ls *.js`; do
    echo "=============================================================================="
    echo "== $f"
    NODE_PATH=$PWD:$PWD/scripts node ./test/$f || exit 1
done
