# Simple Single PostgreSQL environment

## Pre-requisites
- Docker (or compatible product, e.g. Rancher)
- Docker Compose
- `psql` client


## Launch

We launch a stock PostgreSQL container.

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

We can connect directly to the container using the default PostgreSQL port `5432` that is exposed to the host.

```
source .envrc           # Or use direnv
psql "postgresql://${DB_USER}:${DB_PASSWD}@localhost:${DB_PORT}/${DB_NAME}" -c "SELECT version();"
psql "postgresql://${DB_USER}:${DB_PASSWD}@localhost:${DB_PORT}/${DB_NAME}" -t -c "SHOW server_version;"
```

We can connect to PostgreSQL directly from the container if `psql` is not installed locally.
```
docker exec -it ${DB_CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME} -c "SELECT version();"
```

## Teardown

The following will delete all containers resources.

```
docker compose down -v
```

## Debugging

The following are example of the output you should expect when running this tutorial.
```
$ docker compose up -d
[+] Running 3/3
 ✔ Network simple_default                  Created                                                                                                                              0.0s
 ✔ Volume simple_postgresql18-simple-data  Created                                                                                                                              0.0s
 ✔ Container postgresql18-simple           Started                                                                                                                              0.3s

$ docker compose ps
NAME                  IMAGE         COMMAND                  SERVICE    CREATED         STATUS                            PORTS
postgresql18-simple   postgres:18   "docker-entrypoint.s…"   postgres   8 seconds ago   Up 6 seconds (health: starting)   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp

$ docker compose logs
postgresql18-simple  | The files belonging to this database system will be owned by user "postgres".
postgresql18-simple  | This user must also own the server process.
postgresql18-simple  |
postgresql18-simple  | The database cluster will be initialized with locale "en_US.utf8".
postgresql18-simple  | The default database encoding has accordingly been set to "UTF8".
postgresql18-simple  | The default text search configuration will be set to "english".
postgresql18-simple  |
postgresql18-simple  | Data page checksums are enabled.
postgresql18-simple  |
postgresql18-simple  | fixing permissions on existing directory /var/lib/postgresql/18/docker ... ok
postgresql18-simple  | creating subdirectories ... ok
postgresql18-simple  | selecting dynamic shared memory implementation ... posix
postgresql18-simple  | selecting default "max_connections" ... 100
postgresql18-simple  | selecting default "shared_buffers" ... 128MB
postgresql18-simple  | selecting default time zone ... Etc/UTC
postgresql18-simple  | creating configuration files ... ok
postgresql18-simple  | running bootstrap script ... ok
postgresql18-simple  | performing post-bootstrap initialization ... ok
postgresql18-simple  | syncing data to disk ... ok
postgresql18-simple  |
postgresql18-simple  | initdb: warning: enabling "trust" authentication for local connections
postgresql18-simple  | initdb: hint: You can change this by editing pg_hba.conf or using the option -A, or --auth-local and --auth-host, the next time you run initdb.
postgresql18-simple  |
postgresql18-simple  | Success. You can now start the database server using:
postgresql18-simple  |
postgresql18-simple  |     pg_ctl -D /var/lib/postgresql/18/docker -l logfile start
postgresql18-simple  |
postgresql18-simple  | waiting for server to start....2026-02-06 17:18:48.028 UTC [50] LOG:  starting PostgreSQL 18.1 (Debian 18.1-1.pgdg13+2) on aarch64-unknown-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
postgresql18-simple  | 2026-02-06 17:18:48.030 UTC [50] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
postgresql18-simple  | 2026-02-06 17:18:48.033 UTC [56] LOG:  database system was shut down at 2026-02-06 17:18:47 UTC
postgresql18-simple  | 2026-02-06 17:18:48.035 UTC [50] LOG:  database system is ready to accept connections
postgresql18-simple  |  done
postgresql18-simple  | server started
postgresql18-simple  | CREATE DATABASE
postgresql18-simple  |
postgresql18-simple  |
postgresql18-simple  | /usr/local/bin/docker-entrypoint.sh: ignoring /docker-entrypoint-initdb.d/*
postgresql18-simple  |
postgresql18-simple  | waiting for server to shut down....2026-02-06 17:18:48.233 UTC [50] LOG:  received fast shutdown request
postgresql18-simple  | 2026-02-06 17:18:48.234 UTC [50] LOG:  aborting any active transactions
postgresql18-simple  | 2026-02-06 17:18:48.236 UTC [50] LOG:  background worker "logical replication launcher" (PID 59) exited with exit code 1
postgresql18-simple  | 2026-02-06 17:18:48.237 UTC [54] LOG:  shutting down
postgresql18-simple  | 2026-02-06 17:18:48.239 UTC [54] LOG:  checkpoint starting: shutdown immediate
postgresql18-simple  | 2026-02-06 17:18:48.303 UTC [54] LOG:  checkpoint complete: wrote 943 buffers (5.8%), wrote 3 SLRU buffers; 0 WAL file(s) added, 0 removed, 0 recycled; write=0.011 s, sync=0.051 s, total=0.066 s; sync files=303, longest=0.012 s, average=0.001 s; distance=4352 kB, estimate=4352 kB; lsn=0/1B9FBB0, redo lsn=0/1B9FBB0
postgresql18-simple  | 2026-02-06 17:18:48.313 UTC [50] LOG:  database system is shut down
postgresql18-simple  |  done
postgresql18-simple  | server stopped
postgresql18-simple  |
postgresql18-simple  | PostgreSQL init process complete; ready for start up.
postgresql18-simple  |
postgresql18-simple  | 2026-02-06 17:18:48.349 UTC [1] LOG:  starting PostgreSQL 18.1 (Debian 18.1-1.pgdg13+2) on aarch64-unknown-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
postgresql18-simple  | 2026-02-06 17:18:48.349 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
postgresql18-simple  | 2026-02-06 17:18:48.349 UTC [1] LOG:  listening on IPv6 address "::", port 5432
postgresql18-simple  | 2026-02-06 17:18:48.365 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
postgresql18-simple  | 2026-02-06 17:18:48.377 UTC [72] LOG:  database system was shut down at 2026-02-06 17:18:48 UTC
postgresql18-simple  | 2026-02-06 17:18:48.381 UTC [1] LOG:  database system is ready to accept connections


$ psql "postgresql://${DB_USER}:${DB_PASSWD}@localhost:${DB_PORT}/${DB_NAME}" -c "SELECT version();"
                                                         version
--------------------------------------------------------------------------------------------------------------------------
 PostgreSQL 18.1 (Debian 18.1-1.pgdg13+2) on aarch64-unknown-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
(1 row)

$ psql "postgresql://${DB_USER}:${DB_PASSWD}@localhost:${DB_PORT}/${DB_NAME}" -t -c "SHOW server_version;"
 18.1 (Debian 18.1-1.pgdg13+2)

$ docker compose down -v
[+] Running 3/3
 ✔ Container postgresql18-simple           Removed                                                                                                                              0.4s
 ✔ Volume simple_postgresql18-simple-data  Removed                                                                                                                              0.0s
 ✔ Network simple_default                  Removed                                                                                                                              0.5s
```
