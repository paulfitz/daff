#!/bin/bash

# Fail early, fail often
set -e

function test_daff {

    label=$1
    cmd=$2
    name=$3
    location=$4

    if [ ! -e $location ]; then
        echo "Cannot find $location"
        exit 1
    fi

    org="$PWD"

    dir="$PWD/tmp/integration_test"
    rm -rf "$dir"
    mkdir -p "$dir"
    cd $dir
    
    {
        cat<<EOF
#!/bin/bash
$cmd "$org/$location" "\$@"
EOF
    } > $name
    chmod u+x $name

    export PATH=$PWD:$PATH

    function header {
        echo ""
        echo "======================================================"
        echo "$@"
        echo ""
    }

    header "WORKING ON $label: $name"

    header "Check we can execute daff and git"
    which $name
    which git
    $name version
    git --version
    
    header "Create a test git repository"
    mkdir test_repo
    cd test_repo
    git init
    git config user.email "nevyn@example.com"
    git config user.name "Nevyn"
    cp $org/test/data/broken_bridges.csv bridges.csv
    git add bridges.csv
    git commit -m "first version" -a
    cp $org/test/data/bridges.csv bridges.csv
    git commit -m "second version" -a
    cd ..

    header "Check git repository"
    cd test_repo
    git diff HEAD^1 > diff1
    $name git csv
    git diff HEAD^1 > diff2
    cmp diff1 diff2 && {
        echo "Diff did not change, it should have changed"
        exit 1
    } || echo "good"

    cd $org
}

for language in "$@"; do
    if [[ "$language" = "js" ]]; then
        test_daff $language node daff bin/daff.js
    fi
    if [[ "$language" = "py2" ]]; then
        test_daff $language python2 daff.py python_bin/daff.py
    fi
    if [[ "$language" = "py3" ]]; then
        test_daff  $language python3 daff.py python_bin/daff.py
    fi
done



