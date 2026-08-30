#!/bin/bash

pushd "$(dirname "$0")" > /dev/null

mkdir -p bin
mkdir -p ../../0Common/lib

cd src
fpc @fpMeta.cfg StarField.pas $@
ERRCOMP=$?

popd > /dev/null

exit $ERRCOMP
