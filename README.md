# yt-dlp Parallel Downloader

Una suite de automatización de alto rendimiento y robustez para `yt-dlp`, diseñada para el archivado masivo de medios. Este proyecto se centra en la fiabilidad, la mitigación de bloqueos por parte del servidor y la gestión automatizada de listas en entornos Linux.

## Arquitectura y Funcionalidades Principales

### 1. Sistema de Recuperación y Reintentos Inteligentes
El motor implementa un bucle de reintentos de múltiples etapas (máximo 5 intentos) para gestionar interrupciones de red y limitaciones de tasa (rate-limiting) impuestas por el servidor. Al detectar fallos de conexión o errores de acceso (Exit Status 123), el script inicia un periodo de enfriamiento de seguridad:
- **Retroceso Aleatorio (Randomized Backoff)**: Intervalos de espera de entre 30 y 70 segundos para emular el comportamiento humano y evitar bloqueos persistentes de IP.
- **Cuenta Atrás en Tiempo Real**: Un temporizador visual persistente en la terminal informa sobre el tiempo exacto restante antes del siguiente intento de ejecución.

### 2. Sincronización Automatizada de Listas
La suite incluye un mecanismo de "sincronización segura" que cruza el archivo de historial de descargas con las listas de pendientes (`lista_video.txt` / `lista_audio.txt`) en tiempo real:
- **Depuración Automática**: Las entradas descargadas con éxito se eliminan de los archivos de origen inmediatamente después de cada tanda o ante una interrupción.
- **Gestión Atómica del Historial**: El archivo `historial.txt` se vacía tras la sincronización para evitar el crecimiento indefinido del archivo y permitir re-descargas si se añaden URLs manualmente de nuevo.
- **Optimización para Almacenamiento Externo**: La lógica de limpieza está diseñada para evitar bloqueos de entrada/salida (I/O) en unidades externas, utilizando extracción de IDs en memoria.

### 3. Motor de Ejecución en Paralelo
- **Paralelismo de Procesos**: Utiliza `xargs` para gestionar múltiples instancias concurrentes de `yt-dlp`.
- **Concurrencia de Fragmentos**: Divide internamente cada archivo en hasta 10 fragmentos simultáneos para maximizar el uso del ancho de banda.
- **Distribución de Carga**: Las listas de entrada se aleatorizan (`shuf`) antes de la ejecución, permitiendo que múltiples instancias de terminal trabajen sobre la misma lista sin conflictos de recursos.

### 4. Organización y Nomenclatura Avanzada
- **Plantillas Inteligentes**: Elimina prefijos técnicos innecesarios y organiza los nombres de archivo basándose estrictamente en el título del contenido.
- **Categorización Automática**: Detecta títulos de listas de reproducción (playlists) y genera automáticamente subdirectorios para mantener una biblioteca local estructurada.
- **Integración de Metadatos**: Automatiza la incrustación de miniaturas, subtítulos (incluyendo generados automáticamente) y metadatos técnicos.

## Referencia de Comandos

La suite proporciona dos funciones especializadas integradas directamente en el entorno de la shell (`zsh`/`bash`):

### descargar-video [procesos]
Descarga contenido en la máxima calidad de vídeo disponible basándose en las entradas de `lista_video.txt`.
- Por defecto utiliza 3 procesos paralelos si no se especifica un argumento.

### descargar-audio [procesos]
Extrae el audio en formato MP3 (320kbps / VBR 0) de las entradas en `lista_audio.txt`.
- Incluye post-procesamiento automatizado mediante `ffmpeg`.

## Seguridad y Privacidad
- **Operación Anónima**: La extracción de cookies está desactivada por defecto para proteger la cuenta principal del usuario de ser marcada por actividad automatizada.
- **Suplantación de Identidad (User-Agent)**: Emula un entorno moderno de Chrome/Windows para evitar la detección básica de bots.
- **Inhibición del Sistema**: Utiliza `systemd-inhibit` para prevenir que el sistema operativo entre en modo de suspensión o reposo durante las transferencias activas.

## Instalación y Configuración

1. Clone el repositorio en su entorno local.
2. Otorgue permisos de ejecución: `chmod +x install.sh`.
3. Ejecute el instalador: `./install.sh`.
4. Recargue su configuración de shell: `source ~/.zshrc`.

---
Desarrollado por **Francesc Fosas** | 2026
