#!/bin/bash

if [ "k$1" = "k" ]; then
    echo "Supply zip file"
    exit 1
fi

rm -rf /tmp/try_cpp_package
mkdir /tmp/try_cpp_package || exit 1
cp $1 /tmp/try_cpp_package/base.zip || exit 1
cd /tmp/try_cpp_package || exit 1
unzip base.zip || exit 1
cd coopyhx || exit 1
mkdir build || exit 1
cd build || exit 1
cmake -DCREATE_RUBY=TRUE .. || exit 1
make VERBOSE=1 || exit 1



