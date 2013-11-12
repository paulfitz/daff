#!/bin/bash

set -e

ORG="packaging/cpp_recipe"

if [ ! -e "$ORG/build_cpp_package.sh" ] ; then
    echo "Please run as ./$ORG/build_cpp_package.sh output_dir"
    exit 1
fi

which swig || {
    echo "Please install swig"
    exit 1
}

which cmake || {
    echo "Please install cmake"
    exit 1
}

WORK=/tmp/coopyhx_cpp
if [ ! "k$1" = "k" ] ; then
    WORK="$1"
    mkdir -p $WORK
    BASE=$PWD
    cd $WORK
    WORK=$PWD
    cd $BASE
fi

cd $ORG
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
echo "Checking that it works..."

ZIP=$PWD/coopyhx_cpp.zip
cd $ORG
./try_cpp_package.sh $ZIP
echo "Working zip file: $ZIP"

