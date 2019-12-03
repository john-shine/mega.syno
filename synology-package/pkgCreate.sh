#!/bin/bash

tar -czf package.tgz --owner=0 --group=0 ./package/*
mkdir -p build/
mkdir -p conf/
rm -f build/MEGAsync.spk
tar -cvf build/MEGAsync.spk --owner=0 --group=0 scripts/* INFO PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG LICENSE package.tgz conf/
rm -f package.tgz
