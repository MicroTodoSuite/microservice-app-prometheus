# Prometheus Docker Image

Este repositorio contiene una imagen Docker personalizada para ejecutar Prometheus, permitiendo su configuración mediante **variables de entorno** para facilitar su integración en entornos dinámicos como CI/CD o despliegues automatizados.

## Características

- 🔧 Configuración de Prometheus a través de variables de entorno.
- 📦 Basado en un `Dockerfile` minimalista y un `entrypoint.sh` que transforma variables en un archivo de configuración.
- 📈 Incluye soporte para versionamiento semántico automatizado con **semantic-release**.

## Uso

```bash
docker build -t custom-prometheus .
docker run -e PROMETHEUS_SCRAPE_INTERVAL=15s -p 9090:9090 custom-prometheus
```
