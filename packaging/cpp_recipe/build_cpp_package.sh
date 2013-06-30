#!/bin/bash

if [ ! -e "build_cpp_package.sh" ] ; then
    echo "Please run as ./build_cpp_package.sh"
    exit 1
fi

WORK=/tmp/coopyhx_cpp
if [ ! "k$1" = "k" ] ; then
    WORK="$1"
fi

ORG=$PWD

cd ../.. || exit 1
if [ ! -e compile_cpp_for_package.hxml ]; then
    echo "Could not find compile_cpp_for_package.hxml"
    exit 1
fi
make cpp_pack || exit 1
cd $ORG

mkdir -p $WORK 
cd $WORK || exit 1
WORK=$PWD
echo "Working in $WORK"

rm -rf build
mkdir -p build
cd build || exit 1
rm -rf coopyhx || exit 1
cmake $ORG || exit 1
cd coopyhx || exit 1
./fix_for_swig.sh || exit 1
cd .. || exit 1
rm -f coopyhx.zip
zip -r coopyhx coopyhx || exit 1
if [ ! -e coopyhx.zip ]; then
    echo "Failed to create zip in $PWD"
    exit 1
fi
echo "Zip file created with everything needed to compile coopyhx"
ls $PWD/coopyhx.zip



