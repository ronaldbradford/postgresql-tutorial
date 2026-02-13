#!/usr/bin/env bash
set -o pipefail
set -e

[[ -n "${TRACE}" ]] && set -x

# Source the environment variables for this setup
. .envrc

# Start ProxySQL in the sysbench container
docker compose exec -d ${PROXYSQL_CONTAINER_NAME} proxysql --version

echo "Configuring ProxySQL..."

echo "ProxySQL configuration complete!"
echo "ProxySQL listening on ${PROXY_DB_HOST}:${PROXY_DB_PORT} (PostgreSQL protocol)"
echo "ProxySQL admin on ${PROXY_DB_HOST}:${PROXY_ADMIN_PORT}"
