#!/bin/bash

pushd "$(dirname "$0")" > /dev/null

mkdir -p bin
mkdir -p lib

cd src
fpc @fp.cfg StarField.pas $@
ERRCOMP=$?

popd > /dev/null

exit $ERRCOMP
