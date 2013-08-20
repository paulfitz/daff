#!/bin/bash

set -e
cp ../../page/index.html .
cp ../../page/coopyhx.css .
cp ../../page/coopy_handsontable.css .
cp ../../page/coopy/coopy.js coopy
cp ../../page/coopy/scripts/coopy_view.js coopy/scripts
cp ../../page/coopy/coopyhx.js coopy
cp ../../page/coopy/scripts/coopy_handsontable.js coopy/scripts
cp ../../page/coopy/scripts/test_data.js coopy/scripts
git commit -m "update from trunk" -a
git push
