# PostgreSQL Tutorials

1. Simple Standalone PostgreSQL server 

In this [simple](simple/README.md) tutorial we demonstrate how to launch a single PostgreSQL server via docker and connect to the instance.

2. Simple Standalone PostgreSQL server with Benchmark

In this [simple-bencmark](simple-benchmark/README.md) tutorial we extend the first tutorial and add a container running `sysbench` to demonstrate benchmarking the single PostgreSQL server, and the exhaustion of database connections.

3. Simple Standalone PostgreSQL server with ProxySQL

This tutorial introduces [proxysql](https://proxysql.com) demonstrating how to improve on the simple standalone benchmark avoiding the exhaustion of database connection via connection pooling.
