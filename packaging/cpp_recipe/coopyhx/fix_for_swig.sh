#!/bin/bash

ORG=$PWD
if [ ! -e include ]; then
    echo "Cannot find include directory"
    exit 1
fi
cd include/coopy || exit 1
for f in `ls *.h`; do
    cp $f /tmp
    cp $f /tmp/fix_for_swig.hxx
    $ORG/fix_for_swig1.pl /tmp/fix_for_swig.hxx > $f
done
ls $PWD/*.h
cd ../hx || exit 1
grep -v SWIGFIX Object.h > /tmp/Object.h
sed "s|void operator delete|void operator delete(void*){} // SWIGFIX\n   void operator delete|" /tmp/Object.h > Object.h
ls Object.h
