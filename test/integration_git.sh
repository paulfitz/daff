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

cd $org
