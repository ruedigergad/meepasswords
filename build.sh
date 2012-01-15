#!/bin/bash

find . -name *.qml -exec sed -i 's/Qt 4\.7/QtQuick 1\.1/g' {} \;
mv qtc_packaging/debian_harmattan debian
find . -name .svn -exec rm -rf {} \;
rm -rf qtc_packaging
fakeroot dpkg-buildpackage -sa

