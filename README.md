# PostgreSQL Tutorials

The following tutorials introduce the use of [ProxySQL](https://proxysql.com) with [PostgreSQL](https://postgres.org).

## Definitions
- **PostgreSQL** is a powerful, open source object-relational database system that uses and extends the SQL language. [About PostgreSQL](https://www.postgresql.org/about/)
- **ProxySQL** is an open-source, high-performance database proxy that acts as intelligent middleware between applications and database servers that use MySQL, PostgreSQL and products that are MySQL and PostgreSQL wire-compatible. [About ProxySQL](https://proxysql.com/)

---
## Simple Configurations

### 1. Simple Standalone PostgreSQL server

In this [simple](simple/README.md) tutorial we demonstrate how to launch a single PostgreSQL server via Docker and connect to the instance.

### 2. Simple Standalone PostgreSQL server with Benchmark

In this [simple-benchmark](simple-benchmark/README.md) tutorial we extend the first tutorial by adding a container running [sysbench](https://github.com/akopytov/sysbench) and demonstrate benchmarking the single PostgreSQL server, and demonstrate a common situation of the exhaustion of database connections.

### 3. Simple Standalone PostgreSQL server Benchmark introducing ProxySQL

This tutorial introduces [ProxySQL](https://proxysql.com), demonstrating how to improve on the [simple standalone benchmark](simple-benchmark/) avoid the exhaustion of database connections leverage the ProxySQL connection pooling feature.
