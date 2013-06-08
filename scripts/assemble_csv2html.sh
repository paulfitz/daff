#!/bin/bash

if [ ! -e scripts/assemble_csv2html.sh ]; then
    echo "Please call from root coopyhx directory"
    exit 1
fi

target="bin/csv2html.js"
mkdir -p bin

echo "#!/usr/bin/nodejs" > $target
echo "var window = {};" >> $target
cat coopy.js >> $target
cat scripts/coopy_handsontable.js >> $target
echo -n "var prefix = \"" >> $target
cat page/coopy_handsontable.css | sed "s/$/\\\\n\\\\/" >> $target
echo "\";" >> $target
cat scripts/csv2html.js >> $target
chmod u+x $target
