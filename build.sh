#!/bin/sh

workdir=`pwd`
rm -fr build
mkdir -p build
cd build
cmake ..
cmake --build .
cp $workdir/build/src/netcdf.tmp2m.exe $workdir/.
