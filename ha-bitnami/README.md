# Simple HA PostgreSQL Enironment (Bitnami)

## Pre-requisites
- Docker (or compatible product, e.g. Rancher)
- Docker Compose
- `psql` client

## Launch

```
source .envrc           # Or use direnv
docker compose up -d
```

## Validate

Verify the container starts and there are no errors.
```
docker compose ps
docker compose logs
```

## Test

We test by connecting to the ProxySQL port

```
source .envrc           # Or use direnv
APP_USER=appuser
APP_PASSWD=appuser
psql "postgresql://${PROXYSQL_DB_USER}:${PROXYSQL_DB_PASSWD}@localhost:${PROXYSQL_DB_PORT}/${DB_NAME}" -c "SELECT version();"
```

# Connect as postgres
psql -h 127.0.0.1 -p 6133 -U postgres -d mydb
psql "postgresql://${DB_USER}:${DB_PASSWD}@127.0.0.1:${PROXYSQL_DB_PORT}/${DB_NAME}" < demo.sql

REMOTE_ADMIN_USER=radmin
REMOTE_ADMIN_PASSWD=radmin
psql "postgresql://${REMOTE_ADMIN_USER}:${REMOTE_ADMIN_PASSWD}@localhost:${PROXYSQL_ADMIN_PORT}" < proxysql.sql
