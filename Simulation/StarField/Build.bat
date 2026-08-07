#!/bin/bash
@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

pushd "%~dp0"
mkdir bin > nul
mkdir lib > nul

cd src
echo Compilando StarField...
fpc @fp.cfg StarField.pas %*
set "ERRCOMP=!ERRORLEVEL!"

popd

exit /b %ERRCOMP%
