# Script de instalación para yt-dlp Parallel Downloader
# Autor: Francesc Fosas

echo "🛠️  Iniciando instalador de yt-dlp Parallel Downloader..."
echo "👤 Autor: Francesc Fosas"

# Configurar rutas
DEFAULT_DL_DIR="$HOME/Downloads/yt-dlp"
read -p "📂 Introduce la ruta donde se guardarán los vídeos [$DEFAULT_DL_DIR]: " DL_DIR
DL_DIR=${DL_DIR:-$DEFAULT_DL_DIR}

mkdir -p "$DL_DIR"
LISTA_PATH="$DL_DIR/lista_de_descargas.txt"
touch "$LISTA_PATH"

# 1. Instalar configuración de yt-dlp
CONFIG_DIR="$HOME/.config/yt-dlp"
mkdir -p "$CONFIG_DIR"
cat yt-dlp.conf | sed "s|PLACEHOLDER_DIR|$DL_DIR|g" > "$CONFIG_DIR/config"
echo "✅ Configuración instalada en $CONFIG_DIR/config"

# 2. Inyectar función en .zshrc
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    if grep -q "descargar()" "$ZSHRC"; then
        echo "⚠️  La función 'descargar' ya existe en tu .zshrc. Saltando..."
    else
        echo -e "\n# yt-dlp Parallel Downloader Function\nunalias descargar 2>/dev/null\ndescargar() {\n    local list=\"$LISTA_PATH\"\n    local threads=\${1:-3}\n    echo \"🚀 Iniciando \$threads descargas simultáneas...\"\n    shuf \"\$list\" | xargs -P \"\$threads\" -n 1 -I {} yt-dlp -- \"{}\"\n}" >> "$ZSHRC"
        echo "✅ Función inyectada en $ZSHRC"
    fi
else
    echo "❌ No se encontró .zshrc. Copia la función manualmente de README.md"
fi

echo -e "\n✨ ¡Instalación completada!"
echo "👉 Usa 'source ~/.zshrc' para empezar."
echo "👉 Añade enlaces en: $LISTA_PATH"
