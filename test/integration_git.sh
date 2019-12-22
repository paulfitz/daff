#!/bin/bash

# Fail early, fail often
set -e

source scripts/language_environment.sh "$@"

header "Check we can execute daff and git"
which $DAFF_SCRIPT
which git
$DAFF_SCRIPT version
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
$DAFF_SCRIPT git csv
git diff HEAD^1 > diff2
cmp diff1 diff2 && {
    echo "Diff did not change, it should have changed"
    exit 1
} || echo "good"

header "Prepare for a merge test"
sed -i.bak -e "s/Whitestone/Whitestan/" bridges.csv
cd ..
git clone test_repo test_repo2
cd test_repo2
git config user.email "nevyn@example.com"
git config user.name "Nevyn"
$DAFF_SCRIPT git csv
sed -i.bak -e "s/Buck/Duck/" bridges.csv
git commit -m "duck" -a
cd ../test_repo
git commit -m "stan" -a
git pull --no-edit ../test_repo2

# if we flunked eol fixes there'll be "ASCII text, with CRLF line terminators"
file bridges.csv | grep -v CRLF || {
    echo "EOL behavior doesn't look right"
    exit 1
}

cd $org
