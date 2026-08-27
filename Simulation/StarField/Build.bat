@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

pushd "%~dp0"
mkdir bin > nul
mkdir ..\..\0Common\lib > nul

cd src
echo Compilando StarField...
fpc @fp.cfg StarField.pas %*
set "ERRCOMP=!ERRORLEVEL!"

popd

exit /b %ERRCOMP%
