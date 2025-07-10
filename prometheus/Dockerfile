FROM prom/prometheus:v3.4.2

COPY prometheus.yml /etc/prometheus/prometheus.yml

EXPOSE 9090

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD ["wget", "--quiet", "--spider", "http://localhost:9090/-/healthy"]