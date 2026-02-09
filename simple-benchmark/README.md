# Simple Single PostgreSQL environment with Benchmark

## Pre-requisites
- Docker (or compatible product, e.g. Rancher)
- Docker Compose
- `psql` client

## Launch

We launch a stock PostgreSQL container and a second container that is running `sysbench`.

```
source .envrc           # Or use direnv
docker compose up -d
```

## Validate

Verify the containers start and there are no errors.
```
docker compose ps
docker compose logs
source .envrc           # Or use direnv
psql "postgresql://${DB_USER}:${DB_PASSWD}@localhost:${DB_PORT}/${DB_NAME}" -c "SELECT version();"
```

## Benchmark (4 Threads)

This tutorial demonstrates benchmarking via [sysbench](https://github.com/akopytov/sysbench), an open-source, multi-threaded, and modular benchmarking tool used to evaluate system performance.

There is a one-off prepare stage that will pre-populate the database with necessary data to perform the test.
```
TIME=10 ./benchmark.sh prepare
TIME=10 ./benchmark.sh run
```

You will see results like:
```
SQL statistics:
    queries performed:
        read:                            161126
        write:                           46022
        other:                           23026
        total:                           230174
    transactions:                        11506  (1149.23 per sec.)
    queries:                             230174 (22990.00 per sec.)
    ignored errors:                      3      (0.30 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          10.0111s
    total number of events:              11506

Latency (ms):
         min:                                    0.75
         avg:                                    3.47
         max:                                   67.27
         95th percentile:                        5.18
         sum:                                39977.07

Threads fairness:
    events (avg/stddev):           2876.5000/111.61
    execution time (avg/stddev):   9.9943/0.00
```

### Benchmark (10 Threads)

This will run the benchmark with 10 threads.
```
THREADS=10 TIME=10 ./benchmark.sh run
```

You will see results with different throughput.

```
SQL statistics:
    queries performed:
        read:                            145684
        write:                           41568
        other:                           20841
        total:                           208093
    transactions:                        10393  (1000.89 per sec.)
    queries:                             208093 (20040.14 per sec.)
    ignored errors:                      13     (1.25 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          10.3829s
    total number of events:              10393

Latency (ms):
         min:                                    0.86
         avg:                                    9.97
         max:                                 1024.21
         95th percentile:                       14.73
         sum:                               103623.24

Threads fairness:
    events (avg/stddev):           1039.3000/62.43
    execution time (avg/stddev):   10.3623/0.01
```

### Benchmark (20 Threads)

This will run the benchmark with 20 threads.
```
THREADS=20 TIME=10 ./benchmark.sh run
```

You will see results with likely decreased throughput (due to limited cores in docker)

```
SQL statistics:
    queries performed:
        read:                            125440
        write:                           35729
        other:                           17977
        total:                           179146
    transactions:                        8933   (889.20 per sec.)
    queries:                             179146 (17832.32 per sec.)
    ignored errors:                      27     (2.69 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          10.0455s
    total number of events:              8933

Latency (ms):
         min:                                    1.13
         avg:                                   22.43
         max:                                  231.83
         95th percentile:                       44.17
         sum:                               200408.42

Threads fairness:
    events (avg/stddev):           446.6500/11.01
    execution time (avg/stddev):   10.0204/0.01
```


### Benchmark (25 Threads)

This benchmark will fail as the number of threads exceeds the maximum connections to the database, as expected and is the purpose of subsequent tutorials.

```
$ THREADS=25 TIME=10 ./benchmark.sh run
```

```
Running benchmark: oltp_read_write
Threads: 25, Time: 10s, Tables: 10, Rows/table: 10000
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 25
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

FATAL: Connection to database failed: connection to server at "postgresql18-simple-benchmark" (172.19.0.2), port 5432 failed: FATAL:  sorry, too many clients already

FATAL: `thread_init' function failed: /usr/share/sysbench/oltp_common.lua:349: connection creation failed
FATAL: Connection to database failed: connection to server at "postgresql18-simple-benchmark" (172.19.0.2), port 5432 failed: FATAL:  sorry, too many clients already

FATAL: `thread_init' function failed: /usr/share/sysbench/oltp_common.lua:349: connection creation failed
FATAL: Connection to database failed: connection to server at "postgresql18-simple-benchmark" (172.19.0.2), port 5432 failed: FATAL:  sorry, too many clients already

FATAL: `thread_init' function failed: /usr/share/sysbench/oltp_common.lua:349: connection creation failed
FATAL: Connection to database failed: connection to server at "postgresql18-simple-benchmark" (172.19.0.2), port 5432 failed: FATAL:  sorry, too many clients already

FATAL: `thread_init' function failed: /usr/share/sysbench/oltp_common.lua:349: connection creation failed
FATAL: Connection to database failed: connection to server at "postgresql18-simple-benchmark" (172.19.0.2), port 5432 failed: FATAL:  sorry, too many clients already

FATAL: `thread_init' function failed: /usr/share/sysbench/oltp_common.lua:349: connection creation failed
FATAL: Thread initialization failed!
```

## Monitoring

In a separate thread when running the `sysbench` benchmark you can monitor database activity with the following monitoring script:

```
$ ./monitor.sh
```

```
Monitoring PostgreSQL for 60 seconds (polling every 2s)
Time                 | Total Conn | Active | Idle | Idle in Txn | Active Queries
------------------------------------------------------------------------------------
2026-02-06 13:16:01 |         11 |      3 |    0 |           8 |              2
2026-02-06 13:16:03 |         11 |      2 |    1 |           8 |              1
2026-02-06 13:16:05 |         11 |      1 |    1 |           9 |              0
2026-02-06 13:16:07 |         11 |      4 |    0 |           7 |              3
2026-02-06 13:16:10 |          1 |      1 |    0 |           0 |              0
2026-02-06 13:16:12 |          1 |      1 |    0 |           0 |              0
2026-02-06 13:16:14 |          1 |      1 |    0 |           0 |              0
```

Note that in the `THREADS=20 TIME=10 ./benchmark.sh run` test in which the benchmark will succeed, monitoring will produce the following error which is a separate subsequent discussion for separate pool management.

```
$ ./monitor.sh
Monitoring PostgreSQL for 60 seconds (polling every 2s)
Time                 | Total Conn | Active | Idle | Idle in Txn | Active Queries
------------------------------------------------------------------------------------
psql: error: connection to server at "localhost" (::1), port 5432 failed: Connection refused
	Is the server running on that host and accepting TCP/IP connections?
connection to server at "localhost" (127.0.0.1), port 5432 failed: FATAL:  sorry, too many clients already
```

## Teardown
```
docker compose down -v
```

## Debugging
```

$ docker-compose config --services
postgresql18
sysbench

$ docker compose up -d
[+] Running 4/4
 ✔ Network simple-benchmark_default                            Created                                                                                                          0.0s
 ✔ Volume simple-benchmark_postgresql18-simple-benchmark-data  Created                                                                                                          0.0s
 ✔ Container postgresql18-simple-benchmark                     Healthy                                                                                                         10.8s
 ✔ Container sysbench                                          Started                                                                                                         10.8s


$ docker compose ps
NAME                            IMAGE                       COMMAND                  SERVICE        CREATED          STATUS                    PORTS
postgresql18-simple-benchmark   postgres:18                 "docker-entrypoint.s…"   postgresql18   48 seconds ago   Up 47 seconds (healthy)   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp
sysbench                        simple-benchmark-sysbench   "tail -f /dev/null"      sysbench       48 seconds ago   Up 36 seconds


postgresql18-simple-benchmark  | creating subdirectories ... ok
postgresql18-simple-benchmark  | selecting dynamic shared memory implementation ... posix
postgresql18-simple-benchmark  | selecting default "max_connections" ... 100
postgresql18-simple-benchmark  | selecting default "shared_buffers" ... 128MB
postgresql18-simple-benchmark  | selecting default time zone ... Etc/UTC
postgresql18-simple-benchmark  | creating configuration files ... ok
postgresql18-simple-benchmark  | running bootstrap script ... ok
postgresql18-simple-benchmark  | performing post-bootstrap initialization ... ok
postgresql18-simple-benchmark  | initdb: warning: enabling "trust" authentication for local connections
postgresql18-simple-benchmark  | initdb: hint: $ docker compose logs
postgresql18-simple-benchmark  | The files belonging to this database system will be owned by user "postgres".
postgresql18-simple-benchmark  | This user must also own the server process.
postgresql18-simple-benchmark  |
postgresql18-simple-benchmark  | The database cluster will be initialized with locale "en_US.utf8".
postgresql18-simple-benchmark  | The default database encoding has accordingly been set to "UTF8".
postgresql18-simple-benchmark  | The default text search configuration will be set to "english".
postgresql18-simple-benchmark  |
postgresql18-simple-benchmark  | Data page checksums are enabled.
postgresql18-simple-benchmark  |
postgresql18-simple-benchmark  | fixing permissions on existing directory /var/lib/postgresYou can change this by editing pg_hba.conf or using the option -A, or --auth-local and --auth-host, the next time you run initdb.
postgresql18-simple-benchmark  | syncing data to disk ... ok
postgresql18-simple-benchmark  |
postgresql18-simple-benchmark  |
postgresql18-simple-benchmark  | Success. You can now start the database server using:
postgresql18-simple-benchmark  |
postgresql18-simple-benchmark  |     pg_ctl -D /var/lib/postgresql/18/docker -l logfile start
postgresql18-simple-benchmark  |
postgresql18-simple-benchmark  | waiting for server to start....2026-02-06 18:07:32.885 UTC [50] LOG:  starting PostgreSQL 18.1 (Debian 18.1-1.pgdg13+2) on aarch64-unknown-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
postgresql18-simple-benchmark  | 2026-02-06 18:07:32.886 UTC [50] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
postgresql18-simple-benchmark  | 2026-02-06 18:07:32.890 UTC [56] LOG:  database system was shut down at 2026-02-06 18:07:32 UTC
postgresql18-simple-benchmark  | 2026-02-06 18:07:32.893 UTC [50] LOG:  database system is ready to accept connections
postgresql18-simple-benchmark  |  done
postgresql18-simple-benchmark  | server started
postgresql18-simple-benchmark  | CREATE DATABASE
postgresql18-simple-benchmark  |
postgresql18-simple-benchmark  |
postgresql18-simple-benchmark  | /usr/local/bin/docker-entrypoint.sh: ignoring /docker-entrypoint-initdb.d/*
postgresql18-simple-benchmark  |
postgresql18-simple-benchmark  | waiting for server to shut down...2026-02-06 18:07:33.078 UTC [50] LOG:  received fast shutdown request
postgresql18-simple-benchmark  | .2026-02-06 18:07:33.080 UTC [50] LOG:  aborting any active transactions
postgresql18-simple-benchmark  | 2026-02-06 18:07:33.084 UTC [50] LOG:  background worker "logical replication launcher" (PID 59) exited with exit code 1
postgresql18-simple-benchmark  | 2026-02-06 18:07:33.084 UTC [54] LOG:  shutting down
postgresql18-simple-benchmark  | 2026-02-06 18:07:33.085 UTC [54] LOG:  checkpoint starting: shutdown immediate
postgresql18-simple-benchmark  | 2026-02-06 18:07:33.119 UTC [54] LOG:  checkpoint complete: wrote 943 buffers (2.9%), wrote 3 SLRU buffers; 0 WAL file(s) added, 0 removed, 0 recycled; write=0.015 s, sync=0.018 s, total=0.035 s; sync files=303, longest=0.004 s, average=0.001 s; distance=4352 kB, estimate=4352 kB; lsn=0/1B9FBE8, redo lsn=0/1B9FBE8
postgresql18-simple-benchmark  | 2026-02-06 18:07:33.129 UTC [50] LOG:  database system is shut down
postgresql18-simple-benchmark  |  done
postgresql18-simple-benchmark  | server stopped
postgresql18-simple-benchmark  |
postgresql18-simple-benchmark  | PostgreSQL init process complete; ready for start up.
postgresql18-simple-benchmark  |
postgresql18-simple-benchmark  | 2026-02-06 18:07:33.200 UTC [1] LOG:  starting PostgreSQL 18.1 (Debian 18.1-1.pgdg13+2) on aarch64-unknown-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
postgresql18-simple-benchmark  | 2026-02-06 18:07:33.200 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
postgresql18-simple-benchmark  | 2026-02-06 18:07:33.200 UTC [1] LOG:  listening on IPv6 address "::", port 5432
postgresql18-simple-benchmark  | 2026-02-06 18:07:33.212 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
postgresql18-simple-benchmark  | 2026-02-06 18:07:33.221 UTC [72] LOG:  database system was shut down at 2026-02-06 18:07:33 UTC
postgresql18-simple-benchmark  | 2026-02-06 18:07:33.224 UTC [1] LOG:  database system is ready to accept connections

$ THREADS=10 TIME=10 ./benchmark.sh prepare
Preparing test data...
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

Creating table 'sbtest1'...
Inserting 10000 records into 'sbtest1'
Creating a secondary index on 'sbtest1'...
Creating table 'sbtest2'...
Inserting 10000 records into 'sbtest2'
Creating a secondary index on 'sbtest2'...
Creating table 'sbtest3'...
Inserting 10000 records into 'sbtest3'
Creating a secondary index on 'sbtest3'...
Creating table 'sbtest4'...
Inserting 10000 records into 'sbtest4'
Creating a secondary index on 'sbtest4'...
Creating table 'sbtest5'...
Inserting 10000 records into 'sbtest5'
Creating a secondary index on 'sbtest5'...
Creating table 'sbtest6'...
Inserting 10000 records into 'sbtest6'
Creating a secondary index on 'sbtest6'...
Creating table 'sbtest7'...
Inserting 10000 records into 'sbtest7'
Creating a secondary index on 'sbtest7'...
Creating table 'sbtest8'...
Inserting 10000 records into 'sbtest8'
Creating a secondary index on 'sbtest8'...
Creating table 'sbtest9'...
Inserting 10000 records into 'sbtest9'
Creating a secondary index on 'sbtest9'...
Creating table 'sbtest10'...
Inserting 10000 records into 'sbtest10'
Creating a secondary index on 'sbtest10'...

$ TIME=10 ./benchmark.sh run
Running benchmark: oltp_read_write
Threads: 4, Time: 10s, Tables: 10, Rows/table: 10000
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 4
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 4 tps: 1214.75 qps: 24335.92 (r/w/o: 17042.42/4859.01/2434.49) lat (ms,95%): 5.09 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 4 tps: 1068.83 qps: 21385.69 (r/w/o: 14968.68/4279.34/2137.67) lat (ms,95%): 5.37 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 4 tps: 897.25 qps: 17950.75 (r/w/o: 12568.24/3588.01/1794.49) lat (ms,95%): 7.84 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 4 tps: 1141.02 qps: 22840.87 (r/w/o: 15982.44/4575.37/2283.06) lat (ms,95%): 5.18 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 4 tps: 1180.62 qps: 23585.34 (r/w/o: 16512.65/4710.45/2362.25) lat (ms,95%): 5.18 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 4 tps: 1077.87 qps: 21558.48 (r/w/o: 15092.24/4310.50/2155.75) lat (ms,95%): 5.67 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 4 tps: 1283.54 qps: 25668.72 (r/w/o: 17967.50/5130.14/2571.07) lat (ms,95%): 4.57 err/s: 1.00 reconn/s: 0.00
[ 8s ] thds: 4 tps: 1309.88 qps: 26242.65 (r/w/o: 18371.36/5246.53/2624.77) lat (ms,95%): 4.18 err/s: 2.00 reconn/s: 0.00
[ 9s ] thds: 4 tps: 1188.09 qps: 23766.82 (r/w/o: 16642.27/4747.36/2377.18) lat (ms,95%): 4.57 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 3 tps: 1140.78 qps: 22806.65 (r/w/o: 15958.98/4567.10/2280.57) lat (ms,95%): 4.57 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            161126
        write:                           46022
        other:                           23026
        total:                           230174
    transactions:                        11506  (1149.23 per sec.)
    queries:                             230174 (22990.00 per sec.)
    ignored errors:                      3      (0.30 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          10.0111s
    total number of events:              11506

Latency (ms):
         min:                                    0.75
         avg:                                    3.47
         max:                                   67.27
         95th percentile:                        5.18
         sum:                                39977.07

Threads fairness:
    events (avg/stddev):           2876.5000/111.61
    execution time (avg/stddev):   9.9943/0.00


$ docker compose down -v

[+] Running 4/4
 ✔ Container sysbench                                          Removed                                                                                                         10.7s
 ✔ Container postgresql18-simple-benchmark                     Removed                                                                                                          0.7s
 ✔ Volume simple-benchmark_postgresql18-simple-benchmark-data  Removed                                                                                                          0.0s
 ✔ Network simple-benchmark_default                            Removed                                                                                                          0.5s
```
