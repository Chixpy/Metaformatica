#!/bin/bash

pushd "$(dirname "$0")" > /dev/null

TMP_LOG=$(mktemp)
CONTADOR=0

find . -type f -name "build.sh" | while read -r script_path; do
  echo ""
  echo ===================================
  echo Ejecutando: $script_path
  echo ===================================

  script_dir=$(dirname "$script_path")

  pushd "$script_dir" > /dev/null
    bash "./$(basename "$script_path")"
    STATUS=$?
  popd > /dev/null

  if [ $STATUS -ne 0 ]; then
    echo " - $script_dir" >> "TMP_LOG"
  fi
done

if [ ! -s "TMP_LOG" ]; then
  echo "[OK] ¡Todo se compiló correctamente!"
else
  CONTADOR=$(wc -l < "$TMP_LOG")
  echo [ERROR] Se encontraron %CONTFALLOS% prograams con fallos
  echo ""
  cat "$TMP_LOG"
fi

rm -f "$TMP_LOG"

popd > /dev/null
