#!/bin/bash

# Script de instalacion para yt-dlp Parallel Downloader (Versión Robusta 2025)
# Autor: Francesc Fosas

echo -e "\e[1;34mIniciando instalador de yt-dlp Parallel Downloader...\e[0m"
echo "Autor: Francesc Fosas"

# 1. Configuracion de rutas
DEFAULT_DL_DIR="$HOME/Downloads/yt-dlp"
echo ""
echo "--- Configuracion de rutas ---"
read -p "Introduce la ruta de destino para las descargas [$DEFAULT_DL_DIR]: " DL_DIR
DL_DIR=${DL_DIR:-$DEFAULT_DL_DIR}

mkdir -p "$DL_DIR"

# 2. Personalización
echo ""
echo "--- Personalizacion ---"
read -p "Numero de descargas simultaneas [3]: " THREADS
THREADS=${THREADS:-3}

# 3. Instalacion de configuracion de yt-dlp
CONFIG_DIR="$HOME/.config/yt-dlp"
mkdir -p "$CONFIG_DIR"
sed "s|PLACEHOLDER_DIR|$DL_DIR|g" yt-dlp.conf > "$CONFIG_DIR/config"
echo "✅ Configuracion guardada en $CONFIG_DIR/config"

# 4. Integracion en .zshrc
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    if grep -q "_limpiar_listas_yt()" "$ZSHRC"; then
        echo "⚠️  Aviso: Las funciones ya parecen estar en .zshrc. No se han duplicado."
    else
        echo "📦 Integrando funciones avanzadas en $ZSHRC..."
        
        cat << EOF >> "$ZSHRC"

# --- yt-dlp Parallel Downloader (Francesc Fosas) ---
unalias descargar-video 2>/dev/null
unalias descargar-audio 2>/dev/null

_countdown() {
    local secs=\$1
    while [ \$secs -gt 0 ]; do
        echo -ne "\r⏳ Reintentando en: \e[1;36m\$secs\e[0m segundos...     "
        sleep 1
        secs=\$((secs - 1))
    done
    echo -e "\r🔄 Iniciando reintento ahora...                "
}

_limpiar_listas_yt() {
    local h="$DL_DIR/historial.txt"
    local l_v="$DL_DIR/lista_video.txt"
    local l_a="$DL_DIR/lista_audio.txt"
    [ ! -s "\$h" ] && return
    echo -ne "\e[1;33m🧹 Sincronizando listas... \e[0m"
    local ids=\$(awk '{print \$2}' "\$h" | xargs | tr ' ' '|')
    : > "\$h"
    if [ -n "\$ids" ]; then
        sed -i -E "/(\$ids)/d" "\$l_v" 2>/dev/null
        sed -i -E "/(\$ids)/d" "\$l_a" 2>/dev/null
    fi
    echo -e "\e[1;32mOK\e[0m"
}

descargar-video() {
    local list="$DL_DIR/lista_video.txt"
    local threads=\${1:-$THREADS}
    local intento=1
    local max=5
    trap _limpiar_listas_yt INT TERM
    while [ \$intento -le \$max ]; do
        echo "🎬 Intento [\$intento/\$max] - Video..."
        touch "\$list"
        shuf "\$list" | systemd-inhibit --why="Descarga Video" xargs -P "\$threads" -n 1 -I {} yt-dlp --no-ignore-errors -- "{}"
        local ret_code=\$?
        if [ \$ret_code -eq 0 ]; then
            echo "✅ ¡Todo terminado!"; _limpiar_listas_yt; trap - INT TERM; return 0
        elif [ \$ret_code -eq 130 ]; then
            echo -e "\n🛑 Cancelado."; _limpiar_listas_yt; trap - INT TERM; return 130
        else
            echo "⚠️  Error detectado."; _limpiar_listas_yt
            if [ \$intento -lt \$max ]; then
                _countdown \$(( (RANDOM % 40) + 30 )); intento=\$((intento + 1))
            else
                echo "❌ Límite alcanzado."; trap - INT TERM; return 1
            fi
        fi
    done
}

descargar-audio() {
    local list="$DL_DIR/lista_audio.txt"
    local threads=\${1:-$THREADS}
    local intento=1
    local max=5
    trap _limpiar_listas_yt INT TERM
    while [ \$intento -le \$max ]; do
        echo "🎵 Intento [\$intento/\$max] - Audio..."
        touch "\$list"
        shuf "\$list" | systemd-inhibit --why="Descarga Audio" xargs -P "\$threads" -n 1 -I {} yt-dlp -x --audio-format mp3 --audio-quality 0 --no-ignore-errors -- "{}"
        local ret_code=\$?
        if [ \$ret_code -eq 0 ]; then
            echo "✅ ¡Todo terminado!"; _limpiar_listas_yt; trap - INT TERM; return 0
        elif [ \$ret_code -eq 130 ]; then
            echo -e "\n🛑 Cancelado."; _limpiar_listas_yt; trap - INT TERM; return 130
        else
            echo "⚠️  Error detectado."; _limpiar_listas_yt
            if [ \$intento -lt \$max ]; then
                _countdown \$(( (RANDOM % 40) + 30 )); intento=\$((intento + 1))
            else
                echo "❌ Límite alcanzado."; trap - INT TERM; return 1
            fi
        fi
    done
}
# ----------------------------------------------------
EOF
        echo "✅ Funciones integradas correctamente en $ZSHRC"
    fi
else
    echo "❌ Error: No se ha detectado el archivo .zshrc."
fi

# 5. Crear archivos de lista iniciales
touch "$DL_DIR/lista_video.txt"
touch "$DL_DIR/lista_audio.txt"

echo ""
echo -e "\e[1;32mInstalacion completada con exito.\e[0m"
echo "1. Ejecute 'source ~/.zshrc' para activar los comandos."
echo "2. Comandos disponibles: descargar-video, descargar-audio"
echo "3. Ruta de listas: $DL_DIR/"
