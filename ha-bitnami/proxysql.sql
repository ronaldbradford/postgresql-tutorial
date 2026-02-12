-- Check PostgreSQL server status
SELECT * FROM pgsql_servers;
SELECT * FROM pgsql_server_ping_log ORDER BY time_start_us DESC LIMIT 5;
