#!/bin/bash

set -e

if [ ! -e "build_cpp_package.sh" ] ; then
    echo "Please run as ./build_cpp_package.sh"
    exit 1
fi

WORK=/tmp/coopyhx_cpp
if [ ! "k$1" = "k" ] ; then
    WORK="$1"
fi

ORG=$PWD

cd ../..
if [ ! -e compile_cpp_for_package.hxml ]; then
    echo "Could not find compile_cpp_for_package.hxml"
    exit 1
fi
make cpp_package
cd $ORG

mkdir -p $WORK 
cd $WORK
WORK=$PWD
echo "Working in $WORK"

rm -rf build
mkdir -p build
cd build
rm -rf coopyhx
cmake $ORG
cd coopyhx
./fix_for_swig.sh
cd ..
rm -f coopyhx.zip coopyhx_cpp.zip
zip -r coopyhx_cpp coopyhx
if [ ! -e coopyhx_cpp.zip ]; then
    echo "Failed to create zip in $PWD"
    exit 1
fi
echo "Zip file created with everything needed to compile coopyhx"
ls $PWD/coopyhx_cpp.zip



