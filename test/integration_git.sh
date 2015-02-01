#!/bin/bash

# Fail early, fail often
set -e

if [ ! -e bin/daff.js ]; then
    echo "Please run from root directory"
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
exec "$org/bin/daff.js" "\$@"
EOF
} > daff
chmod u+x daff

export PATH=$PWD:$PATH

function header {
    echo ""
    echo "======================================================"
    echo "$@"
    echo ""
}

header "Check we can execute daff and git"
which daff
which git
daff version
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
daff git csv
git diff HEAD^1 > diff2
cmp diff1 diff2 && {
    echo "Diff did not change, it should have changed"
    exit 1
} || echo "good"

