# yt-dlp Parallel Downloader (Arquitectura de Alta Disponibilidad)

Una suite de automatización avanzada para `yt-dlp` diseñada para usuarios que requieren gestionar grandes volúmenes de descargas de forma robusta, rápida y automatizada. Este proyecto soluciona los problemas comunes del uso manual de `yt-dlp`, como los bloqueos de IP, la gestión manual de listas y la interrupción de procesos por fallos de red.

## 🎓 Filosofía y Diseño Didáctico: ¿Por qué este proyecto?

Este sistema no es un simple "envoltorio" para `yt-dlp`. Ha sido diseñado siguiendo principios de ingeniería para maximizar la eficiencia:

1.  **¿Por qué Descargas Paralelas?**
    Muchos servidores de vídeo limitan la velocidad por conexión individual. Al descargar varios archivos simultáneamente (Paralelismo de Proceso) y dividir cada archivo en fragmentos (Paralelismo de Fragmento), saturamos el ancho de banda disponible, reduciendo drásticamente el tiempo total de descarga.
2.  **¿Por qué el "Retroceso Aleatorio" (Random Backoff)?**
    Si un programa intenta reconectar cada 5 segundos exactos, los sistemas de seguridad de YouTube lo identifican como un bot. Nuestro sistema utiliza pausas aleatorias de entre 30 y 70 segundos, desestructurando el patrón y pareciendo un usuario humano que intenta refrescar la página tras un error.
3.  **¿Por qué la Limpieza Atómica de Listas?**
    Gestionar una lista de 200 vídeos manualmente es imposible si el programa falla a mitad. Este sistema "aprende" qué se ha bajado con éxito y lo elimina de tus archivos de texto al instante, manteniendo tus listas siempre actualizadas con el trabajo pendiente real.

---

## 📂 Ecosistema de Archivos

Para que el sistema funcione, interactúa con cuatro archivos clave en tu directorio de descargas:

### 1. `lista_video.txt` y `lista_audio.txt`
Son tus "colas de trabajo". 
- Simplemente pegas las URLs (una por línea) de los vídeos o listas de reproducción que deseas procesar.
- El sistema leerá estas listas, las aleatorizará (para que si lanzas dos terminales, no bajen lo mismo) y empezará el trabajo.

### 2. `historial.txt` (El Diario de Sesión)
Este es un archivo técnico que `yt-dlp` rellena automáticamente cada vez que una descarga se completa con éxito.
- **Función**: Sirve como puente de comunicación entre `yt-dlp` y nuestro script de limpieza.
- **Ciclo de vida**: Tras una tanda de descargas, el script lee este archivo para saber qué borrar de las listas `.txt`. Una vez terminada la limpieza, el sistema **vacía** este historial para que esté listo y "fresco" para la siguiente sesión, evitando que el archivo crezca innecesariamente.

### 3. `yt-dlp.conf` (El Cerebro)
Contiene las reglas maestras: calidad máxima, formatos, incrustación de miniaturas y, sobre todo, la plantilla de nombres. Está configurado para que los archivos tengan nombres limpios y se organicen en carpetas si provienen de una lista de reproducción.

---

## 🛠️ Comandos Disponibles

Tras la instalación, dispondrás de dos comandos globales en tu terminal:

### `descargar-video [n]`
- **Qué hace**: Inicia el motor para descargar las URLs de `lista_video.txt`.
- **Parámetro `[n]`**: Opcional. Indica cuántos vídeos bajar a la vez. Ej: `descargar-video 5` bajará 5 vídeos simultáneamente. Si no pones nada, usará 3 por defecto.
- **Uso ideal**: Series, tutoriales o vídeos que quieras conservar en máxima calidad.

### `descargar-audio [n]`
- **Qué hace**: Procesa `lista_audio.txt`. Convierte automáticamente cada vídeo a MP3 de alta fidelidad (320kbps).
- **Parámetro `[n]`**: Igual que el anterior, define el nivel de paralelismo.
- **Uso ideal**: Podcasts, listas de reproducción musicales o bandas sonoras.

---

## 🔄 El Ciclo de Vida de una Descarga

Cuando ejecutas un comando, el sistema sigue este flujo de trabajo:

1.  **Barajado (Shuffle)**: Desordena tu lista para distribuir la carga.
2.  **Inhibición**: Bloquea el estado de reposo del sistema operativo para evitar que el PC se duerma a mitad de descarga.
3.  **Descarga en Paralelo**: Lanza las instancias de `yt-dlp` configuradas.
4.  **Detección de Interrupción**: 
    - Si todo va bien, el ciclo termina.
    - Si ocurre un error de red o bloqueo (`Exit 123`), el sistema entra en modo recuperación.
5.  **Sincronización de Seguridad**: Limpia las listas `.txt` con lo que se haya logrado bajar hasta ese momento.
6.  **Cuenta Atrás**: Muestra un temporizador en tiempo real en la terminal esperando el tiempo aleatorio de seguridad.
7.  **Reintento**: Reinicia el proceso automáticamente (hasta un máximo de 5 intentos).

---

## 🔐 Seguridad y Privacidad Corporativa

- **Navegación Anónima**: De forma predeterminada, el sistema no comparte tus cookies de navegación. Esto previene que tu cuenta personal de Google pueda ser vinculada a descargas masivas o automatizadas.
- **Protección de Identidad**: El sistema se identifica ante los servidores con un identificador de navegador moderno (User-Agent) para reducir al mínimo la posibilidad de ser bloqueado como tráfico sospechoso.

---

## ⚡ Instalación Rápida

1.  Otorga permisos: `chmod +x install.sh`
2.  Ejecuta: `./install.sh`
3.  Carga el sistema: `source ~/.zshrc`

Desarrollado por **Francesc Fosas** | 2026
