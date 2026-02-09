#!/usr/bin/env bash
set -o pipefail
set -e

[[ -n "${TRACE}" ]] && set -x

# Source the environment variables for this setup
. .envrc

# Start ProxySQL in the sysbench container
docker compose exec -d ${PROXYSQL_CONTAINER_NAME} proxysql --version

echo "Configuring ProxySQL..."

docker exec ${PROXYSQL_CONTAINER_NAME} psql postgresql://admin:admin@${PROXY_DB_HOST}:${PROXY_ADMIN_PORT}/${DB_NAME} << EOF

-- Add PostgreSQL backend server
DELETE FROM pgsql_servers;
INSERT INTO pgsql_servers (hostgroup_id, hostname, port, max_connections)
VALUES (0, '${DB_CONTAINER_NAME}', ${DB_PORT}, 15);

-- Add user for sysbench
DELETE FROM pgsql_users;
INSERT INTO pgsql_users (username, password, default_hostgroup, active)
VALUES ('${DB_USER}', '${DB_PASSWD}', 0, 1);

-- Load configuration to runtime
LOAD PGSQL SERVERS TO RUNTIME;
LOAD PGSQL USERS TO RUNTIME;

-- Save to disk
SAVE PGSQL SERVERS TO DISK;
SAVE PGSQL USERS TO DISK;

-- Show configuration
SELECT * FROM pgsql_servers;
SELECT username, default_hostgroup FROM pgsql_users;

EOF

echo "ProxySQL configuration complete!"
echo "ProxySQL listening on ${PROXY_DB_HOST}:${PROXY_DB_PORT} (PostgreSQL protocol)"
echo "ProxySQL admin on ${PROXY_DB_HOST}:${PROXY_ADMIN_PORT}"
