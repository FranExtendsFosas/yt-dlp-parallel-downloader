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

Simplemente añade tus enlaces al archivo de texto configurado durante la instalación y ejecuta:

```zsh
descargar       # Lanza 3 descargas paralelas por defecto
descargar 5     # Lanza 5 descargas paralelas
```

## ⚙️ Configuración Personalizada

Puedes editar el archivo de configuración en `~/.config/yt-dlp/config` para ajustar los parámetros.

## 🧠 ¿Por qué esta configuración? (Deep Dive)

Este proyecto no solo automatiza la descarga, sino que aplica ingeniería para maximizar el rendimiento:

### 1. Paralelismo a dos niveles
- **Nivel de Proceso (`xargs -P`):** Permite descargar varios archivos `.mp4` distintos al mismo tiempo. Esto es vital porque servidores como OK.ru limitan la velocidad de cada conexión individual.
- **Nivel de Fragmento (`--concurrent-fragments 10`):** Dentro de un mismo vídeo, `yt-dlp` descarga 10 partes a la vez. Esto satura mejor el ancho de banda de conexiones de fibra óptica.

### 2. Evasión de Bloqueos (Anti-Bot)
- **User-Agent Real:** Evitamos que el servidor vea que la petición viene de un script básico de Python. Nos identificamos como un navegador Chrome actualizado.
- **Tiempos de Espera Aleatorios:** Al añadir un retraso de entre 5 y 15 segundos entre descargas, rompemos el patrón rítmico que suelen buscar los sistemas anti-bot.
- **Shuf (Randomize):** Al barajar la lista, permitimos que si usas varias terminales, no ataquen todas al mismo archivo, distribuyendo la carga de peticiones.

### 3. Eficiencia de Datos
- **Buffer de 1M:** Reducimos la frecuencia de escritura en disco, lo cual es más eficiente para la CPU y permite una entrada de datos más fluida en conexiones de alta velocidad.
- **Historial de Descargas:** El archivo `historial.txt` es una base de datos local que evita que `yt-dlp` pierda tiempo siquiera conectando a vídeos que ya tienes descargados.

---

---
Creado por **Francesc Fosas** - 2026
