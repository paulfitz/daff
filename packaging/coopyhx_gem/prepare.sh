#!/bin/bash

if [ "k$1" = "k" ]; then
    echo "Please supply cpp_recipe zip file"
    exit 1
fi

ORG=$PWD

if [ ! -e unpack ]; then
    rm -rf unpack
    mkdir unpack
    cp $1 unpack/base.zip || exit 1
    cd unpack || exit 1
    unzip base.zip || exit 1
    
# generate swig wrapping
    cd $ORG/unpack/coopyhx/ || exit 1
    mkdir build
    cd build || exit 1
    cmake -DCREATE_RUBY=TRUE .. || exit 1
    make coopyhx/fast || echo "OK, I was expecting to fail, taking a shortcut"
    if [ ! -e "coopyhxRUBY_wrap.cxx" ]; then
	echo "Cannot make wrapper"
	exit 1
    fi
    ls *.cxx
fi

cd $ORG
# rm ext/coopyhx/*.c*
# rm ext/coopyhx/*.h
rm -rf ext/include
rm -rf ext/coopyhx/include
rm -rf ext/coopyhx/src
cp -r unpack/coopyhx/include/ ext/coopyhx/include
cp unpack/coopyhx/*.h ext/coopyhx/include
# cp unpack/coopyhx/build/*.h ext/include
cp unpack/coopyhx/build/*.cxx ext/coopyhx/coopyhx.cpp
# cp -r unpack/coopyhx/src ext/coopyhx/src
find unpack/coopyhx/src -iname "*.cpp" -exec cp {} $ORG/ext/coopyhx \;
find unpack/coopyhx/src -iname "*.h" -exec cp {} $ORG/ext/coopyhx/include \;
echo "extern void dummy_function();" > ext/coopyhx/include/coopyhx_rb.h
find ext

