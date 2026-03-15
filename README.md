# yt-dlp Parallel Downloader v2.0

Una suite de automatización avanzada para `yt-dlp` con menú interactivo, descargas paralelas, reintento inteligente y gestión automática de listas de descarga.

---

## 🆕 Novedades en v2.0

- **Menú interactivo `descargar`**: interfaz unificada en terminal con 8 opciones.
- **Apertura de listas en editor gráfico**: edita tus URLs desde una interfaz visual sin salir del flujo.
- **Actualización automática de yt-dlp**: detecta el gestor de paquetes del sistema (Zypper/APT/pip/pipx).
- **Estado de listas en tiempo real**: consulta cuántas URLs tienes pendientes.
- **Descarga de "Ambos"**: lanza audio y vídeo en secuencia con control de cancelación.
- **Creación automática de listas**: si borras los `.txt` por error, se recrean solos.
- **Corrección de bugs**: limpieza al cancelar con Ctrl+C, variables locales protegidas, cancelación en cascada.

---

## 🎓 Filosofía y Diseño

Este sistema no es un simple envoltorio para `yt-dlp`. Sigue principios de ingeniería para maximizar la eficiencia y la robustez:

1. **¿Por qué descargas paralelas?**
   Muchos servidores limitan la velocidad por conexión. Al dividir cada archivo en fragmentos concurrentes, se satura el ancho de banda disponible, reduciendo drásticamente el tiempo total.

2. **¿Por qué el "Retroceso Aleatorio" (Random Backoff)?**
   Si el programa reintenta cada X segundos exactos, los sistemas anti-bot de YouTube lo detectan. El sistema usa pausas aleatorias entre 30 y 70 segundos, imitando el comportamiento humano.

3. **¿Por qué la Limpieza Atómica de Listas?**
   Gestionar manualmente 200 URLs es inviable si el proceso falla a mitad. El sistema elimina automáticamente las URLs completadas de los `.txt`, manteniendo la cola siempre actualizada.

---

## 📂 Archivos del sistema

| Archivo | Descripción |
|---------|-------------|
| `lista_video.txt` | Cola de URLs de vídeo (una por línea) |
| `lista_audio.txt` | Cola de URLs de audio (una por línea) |
| `historial.txt` | Registro interno de descargas completadas |
| `~/.config/yt-dlp/config` | Configuración global de yt-dlp |

---

## 🛠️ Comandos disponibles

### `descargar` — Menú interactivo *(nuevo en v2.0)*

```
=============================
      MENÚ DE DESCARGAS
=============================
  1 - Descargar Audio (MP3)
  2 - Descargar Vídeo (MP4/WebM)
  3 - Descargar Ambos (Audio + Vídeo)
  -----------------------------
  4 - Abrir lista de Audio
  5 - Abrir lista de Vídeo
  6 - Ver estado de las listas
  7 - Actualizar yt-dlp
  8 - Salir
=============================
```

### `descargar-video [n]`
Inicia la descarga de URLs de `lista_video.txt`. El parámetro opcional `n` define el número de conexiones simultáneas por archivo (por defecto 3).

### `descargar-audio [n]`
Procesa `lista_audio.txt` convirtiendo cada vídeo a MP3 de máxima calidad. Mismo parámetro opcional.

---

## 🔄 Ciclo de vida de una descarga

```
URL en lista.txt
     ↓
  Barajado (evita que dos sesiones bajen lo mismo)
     ↓
  systemd-inhibit (evita que el PC se duerma)
     ↓
  yt-dlp en paralelo
     ↓
  ¿Éxito? → Limpieza de lista → Fin
  ¿Ctrl+C? → Limpieza de lista → Fin
  ¿Error de red? → Limpieza parcial → Cuenta atrás → Reintento (hasta 5x)
```

---

## 🔐 Seguridad y Privacidad

- **Navegación anónima por defecto**: no se comparten cookies del navegador, protegiendo la cuenta de Google.
- **User-Agent moderno**: se identifica como un navegador real para reducir bloqueos.
- **OpenSUSE compatible**: la actualización automática detecta Zypper y lo usa correctamente, respetando las restricciones de Python (PEP 668).

---

## ⚡ Instalación

```bash
chmod +x install.sh
./install.sh
source ~/.zshrc
```

El instalador te preguntará:
- La **ruta** donde quieres guardar las descargas (por defecto `~/Downloads/yt-dlp`)
- El número de **conexiones simultáneas** por defecto (por defecto 3)

Y se encargará de:
1. Copiar y configurar `yt-dlp.conf` en `~/.config/yt-dlp/config`
2. Añadir todas las funciones a tu `~/.zshrc`
3. Crear los archivos de lista vacíos

---

## 📦 Compatibilidad

| Sistema | Estado |
|---------|--------|
| openSUSE Tumbleweed | ✅ Probado |
| Ubuntu / Debian / Linux Mint | ✅ Compatible (APT) |
| Arch Linux | ⚠️ Compatible (actualización manual) |
| macOS (Homebrew) | ⚠️ Compatible (actualización manual) |

Requiere: `zsh`, `yt-dlp`, `systemd-inhibit`, `xdg-open`, `ffmpeg`

---

Desarrollado por **Francesc Fosas** | 2026
