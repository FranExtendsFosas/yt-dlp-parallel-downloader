#!/bin/bash

# Script de instalacion para yt-dlp Parallel Downloader
# Autor: Francesc Fosas

echo "Iniciando instalador de yt-dlp Parallel Downloader..."
echo "Autor: Francesc Fosas"

# Configuracion de rutas
DEFAULT_DL_DIR="$HOME/Downloads/yt-dlp"
echo ""
echo "--- Configuracion de rutas ---"
read -p "Introduce la ruta de destino para las descargas [$DEFAULT_DL_DIR]: " DL_DIR
DL_DIR=${DL_DIR:-$DEFAULT_DL_DIR}

mkdir -p "$DL_DIR"

# Archivo de enlaces
read -p "Introduce el nombre del archivo para la lista de enlaces [lista_de_descargas.txt]: " LIST_NAME
LIST_NAME=${LIST_NAME:-lista_de_descargas.txt}

LISTA_PATH="$DL_DIR/$LIST_NAME"
touch "$LISTA_PATH"

echo ""
echo "--- Personalizacion del servicio ---"

# Descargas paralelas
read -p "Numero de descargas simultaneas predeterminado [3]: " THREADS
THREADS=${THREADS:-3}

# Navegador para cookies
read -p "Navegador para extraccion de cookies (brave, chrome, firefox, edge) [brave]: " BROWSER
BROWSER=${BROWSER:-brave}

# Nombre de la funcion
read -p "Nombre para el comando en la terminal [descargar]: " CMD_NAME
CMD_NAME=${CMD_NAME:-descargar}

# 1. Instalacion de configuracion de yt-dlp
CONFIG_DIR="$HOME/.config/yt-dlp"
mkdir -p "$CONFIG_DIR"
cat yt-dlp.conf | \
    sed "s|PLACEHOLDER_DIR|$DL_DIR|g" | \
    sed "s|--cookies-from-browser brave|--cookies-from-browser $BROWSER|g" > "$CONFIG_DIR/config"
echo "Configuracion guardada en $CONFIG_DIR/config"

# 2. Integracion en .zshrc
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    if grep -q "$CMD_NAME()" "$ZSHRC"; then
        echo "Aviso: La funcion '$CMD_NAME' ya existe en .zshrc. No se han realizado cambios."
    else
        echo -e "\n# yt-dlp Parallel Downloader Function (By Francesc Fosas)\nunalias $CMD_NAME 2>/dev/null\n$CMD_NAME() {\n    local list=\"$LISTA_PATH\"\n    local threads=\${1:-$THREADS}\n    echo \"Iniciando \$threads descargas simultaneas...\"\n    shuf \"\$list\" | xargs -P \"\$threads\" -n 1 -I {} yt-dlp -- \"{}\"\n}" >> "$ZSHRC"
        echo "Funcion '$CMD_NAME' integrada correctamente en $ZSHRC"
    fi
else
    echo "Error: No se ha detectado el archivo .zshrc."
fi

echo ""
echo "Instalacion completada."
echo "Ejecute 'source ~/.zshrc' para activar los cambios."
echo "Comando disponible: $CMD_NAME"
echo "Archivo de enlaces: $LISTA_PATH"
