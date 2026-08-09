# Alpine 3.21, not 3.18 (past its supported branch window). Pins the
# prometheus package explicitly too: unpinned, "apk add prometheus" silently
# resolves whatever is newest in Alpine's community repo on build day.
FROM alpine:3.21

# The prometheus package creates its own system user/group (uid 100, gid 101);
# reused below instead of creating a second one under the same name.
RUN apk add --no-cache prometheus=2.53.2-r5 gettext=0.22.5-r0 bash=5.2.37-r0 \
    && mkdir -p /etc/prometheus /prometheus \
    && chown -R prometheus:prometheus /prometheus

COPY prometheus.template.yml /etc/prometheus/prometheus.template.yml
COPY entrypoint.sh /etc/prometheus/entrypoint.sh
RUN chmod +x /etc/prometheus/entrypoint.sh

USER 100:101

EXPOSE 9090

# Shell form is required here for the `|| exit 1` fallback.
# hadolint ignore=DL3025
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
    CMD wget -qO- http://127.0.0.1:9090/-/healthy || exit 1

ENTRYPOINT ["/etc/prometheus/entrypoint.sh"]
