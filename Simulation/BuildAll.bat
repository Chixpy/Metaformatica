@echo off
setlocal enabledelayedexpansion

set "FALLOS="
set "CONTFALLOS=0"

for /r %%f in (Build.bat) do (
  if exist "%%f" (
    echo.
    echo ===================================
    echo Ejecutando: %%f
    echo ===================================

    pushd "%%~dpf"
    call "%%~f"

    if !ERRORLEVEL! neq 0 (
      set /a CONTFALLOS+=1
      set "FALLOS=!FALLOS! - %%~nxf [en %%~pf]^&echo."
    )
    popd
  )
)

if %CONTFALLOS% equ 0 (
  echo [OK] ¡Todo se compiló correctamente!
) else (
  echo [ERROR] Se encontraron %CONTFALLOS% prograams con fallos
  echo.
  cmd /c echo !FALLOS!
  pause
)
