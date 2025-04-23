# Use Alpine Linux 3.18 as the base image
FROM alpine:3.18

# Install Prometheus, gettext (for envsubst), and bash with no cache
RUN apk add --no-cache prometheus gettext bash

# Create necessary directories for config and data storage
RUN mkdir -p /etc/prometheus /prometheus

# Copy the Prometheus template configuration file
COPY prometheus.template.yml /etc/prometheus/prometheus.template.yml

# Copy the entrypoint script
COPY entrypoint.sh /etc/prometheus/entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /etc/prometheus/entrypoint.sh

# Set the entrypoint to run our custom script
ENTRYPOINT ["/etc/prometheus/entrypoint.sh"]