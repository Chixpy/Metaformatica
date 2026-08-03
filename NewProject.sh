#!/bin/bash

# 1. Validar que se hayan pasado exactamente dos parámetros
if [ "$#" -ne 2 ]; then
    echo "❌ Error: Faltan argumentos."
    echo "Uso: $0 <Categoría> <Proyecto>"
    echo "Ejemplo: $0 Fractales MengerSponge"
    exit 1
fi

CATEGORIA="$1"
PROYECTO="$2"
TARGET_DIR="$CATEGORIA/$PROYECTO"

# 2. Comprobar que existe la plantilla base
if [ ! -d "0Base" ]; then
    echo "❌ Error: No se encuentra la carpeta '0Base' en la raíz."
    exit 1
fi

# 3. Evitar sobreescribir un proyecto que ya exista
if [ -d "$TARGET_DIR" ]; then
    echo "⚠️  El proyecto '$TARGET_DIR' ya existe."
    exit 1
fi

echo "🚀 Creando nuevo proyecto '$PROYECTO' en '$CATEGORIA'..."

# Paso 1: Copiar la estructura de 0Base al nuevo directorio
mkdir -p "$CATEGORIA"
cp -r "0Base" "$TARGET_DIR"

# Paso 2 y 3: Renombrar e inyectar "program <Proyecto>;" como primera línea
OLD_PAS="$TARGET_DIR/src/MainProg.pas"
NEW_PAS="$TARGET_DIR/src/${PROYECTO}.pas"

if [ -f "$OLD_PAS" ]; then
    # Creamos la cabecera e imprimimos el contenido original a continuación
    echo "program $PROYECTO;" > "$NEW_PAS"
    cat "$OLD_PAS" >> "$NEW_PAS"
    
    # Eliminamos la plantilla original ya procesada
    rm "$OLD_PAS"
else
    # Por si acaso en 0Base no estuviera el archivo, creamos uno mínimo
    echo "program $PROYECTO;" > "$NEW_PAS"
fi

# Paso 4: Añadir el título al principio del Readme.md
README="$TARGET_DIR/Readme.md"

if [ -f "$README" ]; then
    # Creamos un archivo temporal con el título nuevo y pegamos lo que tuviera el Readme base
    TMP_README=$(mktemp)
    echo "# $PROYECTO" > "$TMP_README"
    echo "" >> "$TMP_README"
    cat "$README" >> "$TMP_README"
    mv "$TMP_README" "$README"
else
    # Si no existía, lo creamos con el título
    echo "# $PROYECTO" > "$README"
fi

# Paso 5: Crear script de bash para compilación
BUILD_SH="$TARGET_DIR/build.sh"
cat <<EOF > "$BUILD_SH"
#!/bin/bash
cd src
fpc @fp.cfg ${PROYECTO}.pas
cd ..
EOF
chmod +x "$BUILD_SH"

# Paso 6: Crear archivo por lotes para compilación
BUILD_BAT="$TARGET_DIR/Build.bat"
cat <<EOF > "$BUILD_BAT"
#!/bin/bash
@echo off
chcp 65001 > nul
cd src
echo Compilando ${PROYECTO}...
fpc @fp.cfg ${PROYECTO}.pas
cd ..

if %ERRORLEVEL% EQU 0 (
  echo.
  echo ¡ÉXITO!
  explorer bin
) else (
  echo.
  error ¡FRACASO!
  pause
)
EOF

echo -e "\e[32m✅ ¡Proyecto '$PROYECTO' creado con éxito!\e[0m"
echo "📂 Ubicación: $TARGET_DIR"
echo "📄 Archivo principal: $TARGET_DIR/src/${PROYECTO}.pas"
