FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    sysbench \
    postgresql-client \
    curl \
    wget \
    lsb-release \
    gnupg2 \
    supervisor \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install ProxySQL 3.0.5
RUN wget -q https://github.com/sysown/proxysql/releases/download/v3.0.5/proxysql_3.0.5-ubuntu22_amd64.deb && \
    dpkg -i proxysql_3.0.5-ubuntu22_amd64.deb || true && \
    apt-get update && \
    apt-get install -y -f && \
    rm proxysql_3.0.5-ubuntu22_amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create ProxySQL data directory
RUN mkdir -p /var/lib/proxysql && \
    chown -R proxysql:proxysql /var/lib/proxysql

# Configure supervisor to run ProxySQL
COPY cnf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
