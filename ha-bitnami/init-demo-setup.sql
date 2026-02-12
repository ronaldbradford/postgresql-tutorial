-- This goes to the primary (hostgroup 10)
CREATE TABLE test(id serial, val text);
INSERT INTO test(val) VALUES ('hello from primary');

-- This goes to the replica (hostgroup 20)
SELECT * FROM test;
