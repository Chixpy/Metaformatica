#!/bin/bash
@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

pushd "%~dp0"
mkdir bin > nul
mkdir lib > nul

cd src
echo Compilando Rain...
fpc @fp.cfg Rain.pas %*
set "ERRCOMP=!ERRORLEVEL!"

popd

exit /b %ERRCOMP%
