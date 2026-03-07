# Script de instalación para yt-dlp Parallel Downloader
# Autor: Francesc Fosas

echo "🛠️  Iniciando instalador de yt-dlp Parallel Downloader..."
echo "👤 Autor: Francesc Fosas"

# Configurar rutas
DEFAULT_DL_DIR="$HOME/Downloads/yt-dlp"
echo "--- Configuración de Rutas ---"
read -p "📂 Introduce la ruta donde se guardarán los vídeos [$DEFAULT_DL_DIR]: " DL_DIR
DL_DIR=${DL_DIR:-$DEFAULT_DL_DIR}

mkdir -p "$DL_DIR"

# Preguntar por el nombre del archivo de lista
read -p "📄 ¿Cómo quieres que se llame el archivo de enlaces? [lista_de_descargas.txt]: " LIST_NAME
LIST_NAME=${LIST_NAME:-lista_de_descargas.txt}

LISTA_PATH="$DL_DIR/$LIST_NAME"
touch "$LISTA_PATH"

echo -e "\n--- Personalización de Descargas ---"
# Preguntar por hilos paralelos
read -p "🚀 ¿Cuántas descargas paralelas quieres por defecto? [3]: " THREADS
THREADS=${THREADS:-3}

# Preguntar por el navegador
read -p "🌐 ¿Qué navegador usas para las cookies? (brave, chrome, firefox, edge) [brave]: " BROWSER
BROWSER=${BROWSER:-brave}

# Preguntar por el nombre del comando
read -p "⌨️  ¿Qué nombre quieres para el comando de descarga? [descargar]: " CMD_NAME
CMD_NAME=${CMD_NAME:-descargar}

# 1. Instalar configuración de yt-dlp
CONFIG_DIR="$HOME/.config/yt-dlp"
mkdir -p "$CONFIG_DIR"
cat yt-dlp.conf | \
    sed "s|PLACEHOLDER_DIR|$DL_DIR|g" | \
    sed "s|--cookies-from-browser brave|--cookies-from-browser $BROWSER|g" > "$CONFIG_DIR/config"
echo "✅ Configuración instalada en $CONFIG_DIR/config"

# 2. Inyectar función en .zshrc
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    if grep -q "$CMD_NAME()" "$ZSHRC"; then
        echo "⚠️  La función '$CMD_NAME' ya existe en tu .zshrc. Saltando..."
    else
        echo -e "\n# yt-dlp Parallel Downloader Function (By Francesc Fosas)\nunalias $CMD_NAME 2>/dev/null\n$CMD_NAME() {\n    local list=\"$LISTA_PATH\"\n    local threads=\${1:-$THREADS}\n    echo \"🚀 Iniciando \$threads descargas simultáneas...\"\n    shuf \"\$list\" | xargs -P \"\$threads\" -n 1 -I {} yt-dlp -- \"{}\"\n}" >> "$ZSHRC"
        echo "✅ Función '$CMD_NAME' inyectada en $ZSHRC"
    fi
else
    echo "❌ No se encontró .zshrc. Configura el alias manualmente."
fi

echo -e "\n✨ ¡Instalación completada!"
echo "👉 Usa 'source ~/.zshrc' para empezar."
echo "👉 Podrás descargar usando el comando: $CMD_NAME"
echo "👉 Añade enlaces en: $LISTA_PATH"
