#!/bin/sh

TMP_LOG=$(mktemp)
CONTADOR=0

find . -type f -name "build.sh" | while read -r script_path; do
  echo ""
  echo ===================================
  echo Ejecutando: %%f
  echo ===================================

  script_dir=$(dirname "$script_path")

  pushd "$script_dir" > /dev/null
    sh "./$(basename "$script_path")"
    STATUS=$?
  popd > /dev/null

  if [ $STATUS -ne 0 ]; then
    echo " - $script_dir" >> "TMP_LOG"
  fi
done

if [ ! -s "TMP_LOG"]; then
  echo "[OK] ¡Todo se compiló correctamente!"
else
  CONTADOR=$(wc -l < "$TMP_LOG")
  echo [ERROR] Se encontraron %CONTFALLOS% prograams con fallos
  echo ""
  cat "$TMP_LOG"
fi

rm -f "$TMP_LOG"
