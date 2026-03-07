# 🚀 yt-dlp Parallel Downloader

Un optimizador y gestor de descargas paralelas para `yt-dlp` diseñado para exprimir conexiones de alta velocidad (Fibra 600Mb+) y evitar bloqueos de servidores.

## ✨ Características

- **Descarga Paralela Mutitérminal:** Descarga múltiples vídeos a la vez (por defecto 3) usando `xargs`.
- **Modo Turbo Fragmentado:** Cada vídeo descarga hasta 10 fragmentos simultáneos.
- **Evasión de Bloqueos:** User-Agent dinámico, intervalos de espera aleatorios y uso de cookies del navegador.
- **Robustez Total:** Ignora errores individuales y continúa con la lista, manteniendo un registro en `historial.txt` para no repetir trabajo.
- **Modo Aleatorio:** Baraja la lista de descarga para permitir que múltiples terminales trabajen juntas sin conflictos.

## 🛠️ Requisitos

- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- `zsh` (Recomendado) o `bash`
- `xargs` y `shuf` (Coreutils de Linux)
- Navegador Brave (para cookies)

## 🚀 Instalación Rápida

1. Clona este repositorio:
   ```bash
   git clone https://github.com/TU_USUARIO/yt-dlp-parallel.git
   cd yt-dlp-parallel
   ```

2. Ejecuta el instalador:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. Recarga tu configuración:
   ```bash
   source ~/.zshrc
   ```

## 📖 Uso

Simplemente añade tus enlaces al archivo `lista_de_descargas.txt` y ejecuta:

```zsh
descargar       # Lanza 3 descargas paralelas por defecto
descargar 5     # Lanza 5 descargas paralelas
```

## ⚙️ Configuración Personalizada

Puedes editar el archivo de configuración en `~/.config/yt-dlp/config` para ajustar:
- El directorio de descarga.
- El número de fragmentos concurrentes.
- El navegador para las cookies.

---
Creado por [Tu Nombre] - 2026
