# Simple Single PostgreSQL environment using ProxySQL

## Pre-requisites
- Docker (or compatible product, e.g. Rancher)
- Docker Compose
- `psql` client

## Launch

This tutorial will launch a single PostgreSQL server, a separate container to run `sysbench` with `proxysql` to demonstrate connection pooling.

```
docker compose build
docker compose up -d
```

## Validate

```
docker compose ps
docker compose logs
source .envrc # Or use direnv
psql "postgresql://${DB_USER}:${DB_PASSWD}@localhost:${DB_PORT}/${DB_NAME}" -c "SELECT version();"
```

We can connect on the container directly to PostgreSQL.
```
docker exec -it postgresql18-simple psql -U ${DB_USER} -d ${DB_NAME} -c "SELECT version();"
```

## ProxySQL Configuration

The addition of a protocol-aware Proxy layer creates a different connection path to the database server via the proxy using the some client connection methods you would use with a typical database.

**ProxySQL** exposes two ports for communication to PostgreSQL.

1. An Admin port (defaults to 6132 for PostgreSQL)
2. A database proxy port (default to 6133 for PostgreSQL)

While the service is running in the container, some additional configuration is required for the regular user to have permissions to connect via the proxy.

This demonstrates the connection failing before this is correctly configured within **ProxySQL**.

```
$ . .envrc
$ psql "postgresql://${DB_USER}:${DB_PASSWD}@localhost:${PROXY_DB_PORT}/${DB_NAME}" -c "SELECT version();"
psql: error: connection to server at "localhost" (::1), port 6133 failed: Connection refused
	Is the server running on that host and accepting TCP/IP connections?
connection to server at "localhost" (127.0.0.1), port 6133 failed: FATAL:  User not found
connection to server at "localhost" (127.0.0.1), port 6133 failed: FATAL:  User not found
```

## ProxySQL Setup

To simpify this first tutorial a script will automatically setup the ProxySQL configuration to run the benchmark. In later tutorials we will analyze this in detail.

```
./proxysql-setup.sh

## Benchmark (4 Threads)
```
## Monitoring

In a separate thread when running the benchmark you can monitor database activity with:

```
$ ./monitor.sh

## Teardown
```
docker compose down -v
```

## Debugging
```
$ docker compose build
[+] Building 189.1s (12/12) FINISHED
 => [internal] load local bake definitions                                                                                                                                      0.0s
 => => reading from stdin 675B                                                                                                                                                  0.0s
 => [internal] load build definition from Dockerfile                                                                                                                            0.0s
 => => transferring dockerfile: 966B                                                                                                                                            0.0s
 => [internal] load metadata for docker.io/library/ubuntu:22.04                                                                                                                 0.1s
 => [internal] load .dockerignore                                                                                                                                               0.0s
 => => transferring context: 2B                                                                                                                                                 0.0s
 => CACHED [1/5] FROM docker.io/library/ubuntu:22.04@sha256:c7eb020043d8fc2ae0793fb35a37bff1cf33f156d4d4b12ccc7f3ef8706c38b1                                                    0.0s
 => => resolve docker.io/library/ubuntu:22.04@sha256:c7eb020043d8fc2ae0793fb35a37bff1cf33f156d4d4b12ccc7f3ef8706c38b1                                                           0.0s
 => [internal] load build context                                                                                                                                               0.0s
 => => transferring context: 65B                                                                                                                                                0.0s
 => [2/5] RUN apt-get update &&     apt-get install -y     sysbench     postgresql-client     curl     wget     lsb-release     gnupg2     supervisor     && apt-get clean &  145.1s
 => [3/5] RUN wget -q https://github.com/sysown/proxysql/releases/download/v3.0.5/proxysql_3.0.5-ubuntu22_amd64.deb &&     dpkg -i proxysql_3.0.5-ubuntu22_amd64.deb || true   36.2s
 => [4/5] RUN mkdir -p /var/lib/proxysql &&     chown -R proxysql:proxysql /var/lib/proxysql                                                                                    0.5s
 => [5/5] COPY cnf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf                                                                                                     0.0s
 => exporting to image                                                                                                                                                          6.8s
 => => exporting layers                                                                                                                                                         6.7s
 => => exporting manifest sha256:453dc0780c8cd42a7f0b52ba1f8d103248868494fea5364a8e9b042ee70c6982                                                                               0.0s
 => => exporting config sha256:5089da5ca20b237a83cdd1fc5a9afca6144ba2d86fbe25b266f83d6f1b299068                                                                                 0.0s
 => => exporting attestation manifest sha256:6aac107e04cd208a9cbcc719fc3083fb1313e239e40e74a59fc39e7c2c16b21d                                                                   0.0s
 => => exporting manifest list sha256:2c313a8017d10afcd6d415d28495e9610173de0ad5b3dd1ab9dfc8c2c6b3d70b                                                                          0.0s
 => => naming to docker.io/library/simple-proxysql-sysbench-proxysql:latest                                                                                                     0.0s
 => resolving provenance for metadata file                                                                                                                                      0.0s
[+] Building 1/1
 ✔ simple-proxysql-sysbench-proxysql  Built                                                                                                                                     0.0s

$ docker compose up -d
[+] Running 5/5
 ✔ Network simple-proxysql_default                  Created                                                                                                                     0.0s
 ✔ Volume simple-proxysql_sysbench-proxysql-data    Created                                                                                                                     0.0s
 ✔ Volume simple-proxysql_postgresql18-simple-data  Created                                                                                                                     0.0s
 ✔ Container postgresql18-simple                    Healthy                                                                                                                    10.8s
 ✔ Container sysbench-proxysql                      Started                                                                                                                    10.9s


$ docker compose ps
NAME                  IMAGE                               COMMAND                  SERVICE             CREATED          STATUS                    PORTS
postgresql18-simple   postgres:18                         "docker-entrypoint.s…"   postgresql18        42 seconds ago   Up 41 seconds (healthy)   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp
sysbench-proxysql     simple-proxysql-sysbench-proxysql   "/usr/bin/supervisor…"   sysbench-proxysql   42 seconds ago   Up 30 seconds             0.0.0.0:6132-6133->6132-6133/tcp, [::]:6132-6133->6132-6133/tcp

$ docker compose down -v
[+] Running 5/5
 ✔ Container sysbench-proxysql                      Removed                                                                                                                     0.8s
 ✔ Container postgresql18-simple                    Removed                                                                                                                     0.5s
 ✔ Volume simple-proxysql_sysbench-proxysql-data    Removed                                                                                                                     0.0s
 ✔ Volume simple-proxysql_postgresql18-simple-data  Removed                                                                                                                     0.0s
 ✔ Network simple-proxysql_default                  Removed                                                                                                                     0.5s

```
