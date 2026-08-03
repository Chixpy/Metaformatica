#!/bin/bash
@echo off
chcp 65001 > nul
cd src
echo Compilando Merger...
fpc Merger.pas
cd ..

if %ERRORLEVEL% EQU 0 (
  echo.
  echo ¡ÉXITO!
  if exist bin\x86_64-win64\ (
    explorer bin\x86_64-win64
  ) else if exist bin\i386-win32\ (
    explorer bin\i386-win32
  ) else if exist bin\i386-win32\ (
    explorer bin\i386-win32
  )
) else (
  echo.
  error ¡FRACASO!
  pause
)
