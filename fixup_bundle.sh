#!/bin/bash

#This script fixes linking on macosx so you can put
#libcom-api.dylib along side core.so and it can find it
#without using DYLD_LIBRARY_PATH

CORE=$*

echo $CORE

DYLIB=libcom-api.dylib

OLD_PATH=`otool -L $CORE | grep $DYLIB | cut -d'(' -f1`
NEW_PATH="@loader_path/$DYLIB"

#easy way to trim off tabs
OLD_PATH=`echo $OLD_PATH`

echo "$OLD_PATH -> $NEW_PATH"
install_name_tool -change $OLD_PATH $NEW_PATH $CORE

