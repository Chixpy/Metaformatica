@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

pushd "%~dp0"
mkdir bin > nul
mkdir ..\..\0Common\lib > nul

cd src
echo Compilando Fireworks...
fpc @fpMeta.cfg Fireworks.pas %*
set "ERRCOMP=!ERRORLEVEL!"

popd

exit /b %ERRCOMP%
