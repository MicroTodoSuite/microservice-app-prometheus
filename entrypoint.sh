#!/bin/sh
set -e # Exit on any error

# Generate config from template with env vars
envsubst < /etc/prometheus/prometheus.template.yml > /tmp/prometheus.yml

# Start Prometheus with generated config
exec prometheus --config.file=/tmp/prometheus.yml --storage.tsdb.path=/prometheus

