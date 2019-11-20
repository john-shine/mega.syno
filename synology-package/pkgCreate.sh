#!/bin/bash

tar -czf package.tgz ./package/*
mkdir -p build/
mkdir -p conf/
rm -f build/MEGAsync.spk
tar -cvf build/MEGAsync.spk scripts/* INFO PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG LICENSE package.tgz conf/
rm -f package.tgz
