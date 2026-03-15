#!/bin/bash

# =============================================================
# Script de instalación - yt-dlp Parallel Downloader v2.0
# Autor: Francesc Fosas | 2026
# =============================================================

echo -e "\e[1;34m"
echo "╔══════════════════════════════════════════════╗"
echo "║   yt-dlp Parallel Downloader - Instalador   ║"
echo "║             Francesc Fosas 2026              ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "\e[0m"

# --- 1. Ruta de descargas ---
DEFAULT_DL_DIR="$HOME/Downloads/yt-dlp"
echo "--- Configuración de rutas ---"
read -p "Introduce la ruta de destino para las descargas [$DEFAULT_DL_DIR]: " DL_DIR
DL_DIR=${DL_DIR:-$DEFAULT_DL_DIR}
mkdir -p "$DL_DIR"
echo "✅ Carpeta de descargas: $DL_DIR"

# --- 2. Hilos por defecto ---
echo ""
echo "--- Paralelismo ---"
read -p "Número de conexiones simultáneas por archivo [3]: " THREADS
THREADS=${THREADS:-3}
echo "✅ Conexiones simultáneas: $THREADS"

# --- 3. Instalación del config de yt-dlp ---
echo ""
CONFIG_DIR="$HOME/.config/yt-dlp"
mkdir -p "$CONFIG_DIR"
sed "s|PLACEHOLDER_DIR|$DL_DIR|g" yt-dlp.conf > "$CONFIG_DIR/config"
echo "✅ Configuración de yt-dlp guardada en: $CONFIG_DIR/config"

# --- 4. Integración en .zshrc ---
echo ""
ZSHRC="$HOME/.zshrc"

if [ ! -f "$ZSHRC" ]; then
    echo "❌ Error: No se ha encontrado el archivo .zshrc. ¿Tienes Zsh instalado?"
    exit 1
fi

if grep -q "_limpiar_listas_yt()" "$ZSHRC"; then
    echo "⚠️  Las funciones ya existen en .zshrc. No se duplicarán."
    echo "   Si quieres reinstalar, elimina primero el bloque antiguo de .zshrc."
else
    echo "📦 Integrando funciones en $ZSHRC..."

    cat <<'ZSHBLOCK' >> "$ZSHRC"

# ============================================================
# yt-dlp Parallel Downloader v2.0 (Francesc Fosas)
# ============================================================
unalias descargar 2>/dev/null

# Cuenta atrás visible en terminal
_countdown() {
    local secs=$1
    while [ $secs -gt 0 ]; do
        echo -ne "\r⏳ Reintentando en: \e[1;36m$secs\e[0m segundos...     "
        sleep 1 || return 130
        secs=$((secs - 1))
    done
    echo -e "\r🔄 Iniciando reintento ahora...                "
}

# Limpieza atómica de listas (elimina URLs ya descargadas)
_limpiar_listas_yt() {
    local h="DL_DIR_PLACEHOLDER/historial.txt"
    local l_v="DL_DIR_PLACEHOLDER/lista_video.txt"
    local l_a="DL_DIR_PLACEHOLDER/lista_audio.txt"
    [ ! -s "$h" ] && return
    echo -ne "\e[1;33m🧹 Actualizando listas... \e[0m"
    local ids=$(awk '{print $2}' "$h" | xargs | tr ' ' '|')
    : > "$h"
    if [ -n "$ids" ]; then
        sed -i -E "/($ids)/d" "$l_v" 2>/dev/null
        sed -i -E "/($ids)/d" "$l_a" 2>/dev/null
    fi
    echo -e "\e[1;32mOK\e[0m"
}

# Descarga de VÍDEOS con reintento inteligente
descargar-video() {
    local list="DL_DIR_PLACEHOLDER/lista_video.txt"
    local hilos_archivos=1
    local partes=${1:-THREADS_PLACEHOLDER}
    local intento=1
    local max=5
    trap _limpiar_listas_yt INT TERM
    echo "🎬 Iniciando descargas de VÍDEO (Conexiones: $partes)..."
    while [ $intento -le $max ]; do
        echo "🔄 Intento [$intento/$max]..."
        shuf "$list" | systemd-inhibit --why="Descargando vídeos" \
            xargs -P "$hilos_archivos" -n 1 -I {} \
            yt-dlp -N "$partes" --sleep-interval 5 --max-sleep-interval 15 --no-ignore-errors -- "{}"
        local ret_code=$?
        if [ $ret_code -eq 0 ]; then
            echo "✅ ¡Todo terminado!"; _limpiar_listas_yt; trap - INT TERM; return 0
        elif [ $ret_code -eq 130 ]; then
            echo -e "\n🛑 Detenido por el usuario."; _limpiar_listas_yt; trap - INT TERM; return 130
        else
            echo "⚠️  Interrupción detectada (error de red/bloqueo)."; _limpiar_listas_yt
            if [ $intento -lt $max ]; then
                local pausa=$(( (RANDOM % 40) + 30 ))
                _countdown $pausa || { echo -e "\n🛑 Cancelado."; trap - INT TERM; return 130; }
                intento=$((intento + 1))
            else
                echo "❌ Límite de reintentos alcanzado."; trap - INT TERM; return 1
            fi
        fi
    done
}

# Descarga de AUDIO (MP3 máxima calidad) con reintento inteligente
descargar-audio() {
    local list="DL_DIR_PLACEHOLDER/lista_audio.txt"
    local hilos_archivos=1
    local partes=${1:-THREADS_PLACEHOLDER}
    local intento=1
    local max_intentos=5
    trap _limpiar_listas_yt INT TERM
    echo "🎵 Iniciando descargas de AUDIO..."
    while [ $intento -le $max_intentos ]; do
        echo "🔄 Intento [$intento/$max_intentos]..."
        shuf "$list" | systemd-inhibit --why="Descargando audio" \
                                       --who="descargar-audio" \
                                       --what=idle:sleep \
            xargs -P "$hilos_archivos" -n 1 -I {} \
            yt-dlp -N "$partes" --sleep-interval 5 --max-sleep-interval 15 \
            -x --audio-format mp3 --audio-quality 0 \
            --no-ignore-errors --no-write-subs --no-write-auto-subs -- "{}"
        local ret_code=$?
        if [ $ret_code -eq 0 ]; then
            echo "✅ ¡Todo el audio completado!"; _limpiar_listas_yt; trap - INT TERM; return 0
        elif [ $ret_code -eq 130 ]; then
            echo -e "\n🛑 Cancelado por usuario."; _limpiar_listas_yt; trap - INT TERM; return 130
        else
            if [ $intento -lt $max_intentos ]; then
                local pausa=$(( (RANDOM % 61) + 30 ))
                _limpiar_listas_yt
                _countdown $pausa || { echo -e "\n🛑 Cancelado."; trap - INT TERM; return 130; }
                intento=$((intento + 1))
            else
                echo "❌ Límite superado."; _limpiar_listas_yt; trap - INT TERM; return 1
            fi
        fi
    done
}

# Menú interactivo principal
descargar() {
    local l_v="DL_DIR_PLACEHOLDER/lista_video.txt"
    local l_a="DL_DIR_PLACEHOLDER/lista_audio.txt"
    local opcion _p

    while true; do
        echo -e "\n\e[1;36m=============================\e[0m"
        echo -e "      \e[1;33mMENÚ DE DESCARGAS\e[0m"
        echo -e "\e[1;36m=============================\e[0m"
        echo -e "  \e[1;32m1\e[0m - Descargar \e[1;33mAudio\e[0m (MP3)"
        echo -e "  \e[1;32m2\e[0m - Descargar \e[1;33mVídeo\e[0m (MP4/WebM)"
        echo -e "  \e[1;32m3\e[0m - Descargar \e[1;33mAmbos\e[0m (Audio + Vídeo)"
        echo -e "  \e[1;36m-----------------------------\e[0m"
        echo -e "  \e[1;32m4\e[0m - \e[1;36mAbrir\e[0m lista de Audio"
        echo -e "  \e[1;32m5\e[0m - \e[1;36mAbrir\e[0m lista de Vídeo"
        echo -e "  \e[1;32m6\e[0m - \e[1;34mVer estado\e[0m de las listas"
        echo -e "  \e[1;32m7\e[0m - \e[1;35mActualizar\e[0m yt-dlp"
        echo -e "  \e[1;31m8\e[0m - \e[1;31mSalir\e[0m"
        echo -e "\e[1;36m=============================\e[0m"
        echo -ne "\e[1;32mSelecciona una opción [1-8]:\e[0m "
        read -r opcion

        case "$opcion" in
            1) descargar-audio; return 0 ;;
            2) descargar-video; return 0 ;;
            3)
                descargar-audio
                local _ret=$?
                if [ $_ret -eq 130 ]; then
                    echo -e "\n🛑 Audio cancelado. No se iniciará la descarga de vídeo."
                    return 130
                fi
                descargar-video; return 0
                ;;
            4)
                [ ! -f "$l_a" ] && { mkdir -p "$(dirname $l_a)" && touch "$l_a" && echo -e "\e[1;33m⚠️  Archivo creado: $l_a\e[0m"; }
                xdg-open "$l_a" </dev/null &>/dev/null
                echo -e "\n\e[1;32mLista de audio abierta en el editor gráfico.\e[0m"
                echo -ne "\e[1;33m↵  Pulsa [Enter] para volver al menú...\e[0m"; read -r _p
                ;;
            5)
                [ ! -f "$l_v" ] && { mkdir -p "$(dirname $l_v)" && touch "$l_v" && echo -e "\e[1;33m⚠️  Archivo creado: $l_v\e[0m"; }
                xdg-open "$l_v" </dev/null &>/dev/null
                echo -e "\n\e[1;32mLista de vídeo abierta en el editor gráfico.\e[0m"
                echo -ne "\e[1;33m↵  Pulsa [Enter] para volver al menú...\e[0m"; read -r _p
                ;;
            6)
                local a_count v_count
                a_count=$(grep -c "^http" "$l_a" 2>/dev/null || echo 0)
                v_count=$(grep -c "^http" "$l_v" 2>/dev/null || echo 0)
                echo -e "\n\e[1;34m>>> ESTADO DE LAS LISTAS <<<\e[0m"
                echo -e "🎵 Audios pendientes: \e[1;33m$a_count\e[0m"
                echo -e "🎬 Vídeos pendientes: \e[1;33m$v_count\e[0m"
                echo -ne "\n\e[1;33m↵  Pulsa [Enter] para volver al menú...\e[0m"; read -r _p
                ;;
            7)
                echo -e "\n\e[1;35mBuscando actualizaciones para yt-dlp...\e[0m"
                if command -v zypper &>/dev/null; then
                    echo "Detectado Zypper (openSUSE). Actualizando..."
                    sudo zypper update yt-dlp
                elif command -v pipx &>/dev/null && pipx list 2>/dev/null | grep -q "yt-dlp"; then
                    pipx upgrade yt-dlp
                elif command -v pip &>/dev/null && pip show yt-dlp &>/dev/null; then
                    pip install -U --break-system-packages yt-dlp 2>/dev/null || sudo zypper update yt-dlp
                elif command -v apt-get &>/dev/null && dpkg -l 2>/dev/null | grep -q ' yt-dlp '; then
                    sudo apt-get update && sudo apt-get install --only-upgrade yt-dlp
                else
                    echo -e "\e[1;33m⚠️ No se pudo detectar el gestor. Actualiza manualmente.\e[0m"
                fi
                echo -ne "\n\e[1;33m↵  Pulsa [Enter] para volver al menú...\e[0m"; read -r _p
                ;;
            8|q|Q)
                echo -e "\n\e[1;31mSaliendo...\e[0m"; return 0 ;;
            *)
                echo -e "\n\e[1;31m❌ Opción no válida.\e[0m"
                echo -ne "\e[1;33m↵  Pulsa [Enter] para continuar...\e[0m"; read -r _p
                ;;
        esac
    done
}
# ============================================================
ZSHBLOCK

    # Reemplazar los placeholders con las rutas reales
    sed -i "s|DL_DIR_PLACEHOLDER|$DL_DIR|g" "$ZSHRC"
    sed -i "s|THREADS_PLACEHOLDER|$THREADS|g" "$ZSHRC"
    echo "✅ Funciones integradas correctamente en $ZSHRC"
fi

# --- 5. Crear archivos de lista si no existen ---
touch "$DL_DIR/lista_video.txt"
touch "$DL_DIR/lista_audio.txt"
touch "$DL_DIR/historial.txt"
echo "✅ Archivos de lista creados en: $DL_DIR/"

# --- 6. Resumen final ---
echo ""
echo -e "\e[1;32m╔══════════════════════════════════════════════╗\e[0m"
echo -e "\e[1;32m║        Instalación completada con éxito      ║\e[0m"
echo -e "\e[1;32m╚══════════════════════════════════════════════╝\e[0m"
echo ""
echo "  Siguiente paso → ejecuta:  source ~/.zshrc"
echo ""
echo "  Comandos disponibles:"
echo "    descargar          → Menú interactivo completo"
echo "    descargar-audio    → Descarga directa de audio"
echo "    descargar-video    → Descarga directa de vídeo"
echo ""
echo "  Ruta de listas: $DL_DIR/"
echo ""
