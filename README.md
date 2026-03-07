# yt-dlp Parallel Downloader

Optimizador y gestor de descargas paralelas para `yt-dlp`, diseñado para maximizar el rendimiento en conexiones de alta velocidad y mitigar el riesgo de bloqueos por parte de los servidores.

## Características principales

- **Paralelismo de procesos:** Gestión de múltiples descargas simultáneas mediante `xargs`.
- **Segmentación de descarga:** Configuración de hasta 10 fragmentos concurrentes por archivo para saturar el ancho de banda.
- **Evasión de sistemas anti-bot:** Implementación de User-Agent dinámico, intervalos de espera aleatorios y extracción de cookies de sesión.
- **Gestión de errores:** Registro de descargas finalizadas en `historial.txt` e ignorancia de errores individuales para evitar la interrupción de la cola.
- **Distribución de carga:** Aleatorización de la lista de descargas para permitir la ejecución concurrente desde múltiples terminales.

## Requisitos del sistema

- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- `zsh` o `bash`
- `xargs` y `shuf` (GNU Coreutils)
- Navegador compatible para la extracción de cookies (Brave, Chrome, Firefox o Edge)

## Instalación

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/TU_USUARIO/yt-dlp-parallel.git
   cd yt-dlp-parallel
   ```

2. Ejecutar el script de instalación:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. Recargar la configuración de la shell:
   ```bash
   source ~/.zshrc
   ```

## Instrucciones de uso

Añada los enlaces al archivo de texto especificado durante la instalación y ejecute el comando configurado:

```zsh
descargar       # Ejecución con el límite predeterminado (ej. 3 descargas simultáneas)
descargar 5     # Especificación manual a 5 descargas simultáneas
```

## Análisis técnico y justificación

Este proyecto aplica criterios técnicos específicos para optimizar el flujo de trabajo:

### 1. Paralelismo multinivel
- **Nivel de Proceso:** El uso de `xargs -P` permite gestionar varias descargas de archivos independientes. Esto es fundamental debido a las limitaciones de ancho de banda por conexión única impuestas por proveedores como OK.ru.
- **Nivel de Fragmento:** Mediante `--concurrent-fragments`, se dividen los archivos en segmentos que se descargan en paralelo, optimizando el uso de conexiones de fibra óptica.

### 2. Mitigación de bloqueos
- **Identidad de Navegador:** Se utiliza un User-Agent de un navegador moderno para evitar la identificación del tráfico como automatizado por Python.
- **Intervalos de latencia:** La implementación de latencias aleatorias entre 5 y 15 segundos desestructura los patrones de acceso rítmico, reduciendo la probabilidad de detección por sistemas anti-bot.
- **Aleatorización mediante shuf:** Permite que distintas instancias del script procesen diferentes partes de la lista simultáneamente sin entrar en conflicto.

### 3. Eficiencia en la persistencia de datos
- **Optimización de Buffer:** El uso de un búfer de 1MB minimiza las operaciones de escritura en disco, mejorando la eficiencia en sistemas con alta tasa de transferencia.
- **Archivo de archivo (Archive file):** El seguimiento mediante `historial.txt` previene el procesamiento redundante de enlaces ya descargados.

---

Desarrollado por **Francesc Fosas** - 2026
