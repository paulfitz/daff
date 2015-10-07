#!/bin/bash

language="$1"

export DAFF_LANGUAGE="$language"

if [[ "$language" = "js" ]]; then
    export DAFF_INTERPRETER=node
    export DAFF_SCRIPT=daff
    export DAFF_PATH=bin/daff.js
fi
if [[ "$language" = "py2" ]]; then
    export DAFF_INTERPRETER=python2
    export DAFF_SCRIPT=daff.py
    export DAFF_PATH=python_bin/daff.py
fi
if [[ "$language" = "py3" ]]; then
    export DAFF_INTERPRETER=python3
    export DAFF_SCRIPT=daff.py
    export DAFF_PATH=python_bin/daff.py
fi
if [[ "$language" = "" ]]; then
    echo "Language not specified"
    exit 1
fi
if [[ "$DAFF_SCRIPT" = "" ]]; then
    echo "Language not recognized"
    exit 1
fi
if [ ! -e $DAFF_PATH ]; then
    echo "Cannot find $DAFF_PATH"
    exit 1
fi

function header {
    echo ""
    echo "======================================================"
    echo "$@"
    echo ""
}

header "WORKING ON $DAFF_LANGUAGE: $DAFF_SCRIPT"

org="$PWD"

dir="$PWD/tmp/integration_test"
rm -rf "$dir"
mkdir -p "$dir"
cd $dir
    
{
    cat<<EOF
#!/bin/bash
$DAFF_INTERPRETER "$org/$DAFF_PATH" "\$@"
EOF
} > $DAFF_SCRIPT
chmod u+x $DAFF_SCRIPT

export PATH=$PWD:$PATH
