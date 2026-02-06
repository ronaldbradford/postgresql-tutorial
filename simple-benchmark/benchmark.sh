#!/usr/bin/env bash

set -e

# Default values
TABLES=${TABLES:-10}
TABLE_SIZE=${TABLE_SIZE:-10000}
THREADS=${THREADS:-4}
TIME=${TIME:-60}
REPORT_INTERVAL=${REPORT_INTERVAL:-1}
TEST_TYPE=${TEST_TYPE:-oltp_read_write}

# Base sysbench command
SYSBENCH_CMD="docker compose exec sysbench sysbench \
  --db-driver=pgsql \
  --pgsql-host=${DB_CONTAINER_NAME} \
  --pgsql-port=${DB_PORT} \
  --pgsql-user=${DB_USER} \
  --pgsql-password=${DB_PASSWD} \
  --pgsql-db=${DB_NAME} \
  --tables=${TABLES} \
  --table-size=${TABLE_SIZE}"

usage() {
  echo "Usage: $0 {prepare|run|cleanup} [test_type]"
  echo ""
  echo "Commands:"
  echo "  prepare  - Create tables and insert test data"
  echo "  run      - Execute benchmark"
  echo "  cleanup  - Remove test data"
  echo ""
  echo "Test types:"
  echo "  oltp_read_write (default)"
  echo "  oltp_read_only"
  echo "  oltp_write_only"
  echo "  oltp_insert"
  echo "  oltp_update_index"
  echo "  oltp_delete"
  echo ""
  echo "Environment variables:"
  echo "  TABLES=${TABLES}"
  echo "  TABLE_SIZE=${TABLE_SIZE}"
  echo "  THREADS=${THREADS}"
  echo "  TIME=${TIME}"
  echo "  REPORT_INTERVAL=${REPORT_INTERVAL}"
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

COMMAND=$1
TEST_TYPE=${2:-$TEST_TYPE}

case $COMMAND in
  prepare)
    echo "Preparing test data..."
    ${SYSBENCH_CMD} "${TEST_TYPE}" prepare
    ;;
  run)
    echo "Running benchmark: $TEST_TYPE"
    echo "Threads: $THREADS, Time: ${TIME}s, Tables: $TABLES, Rows/table: $TABLE_SIZE"
    ${SYSBENCH_CMD} \
      --threads="${THREADS}" \
      --time="${TIME}" \
      --report-interval="${REPORT_INTERVAL}" \
      "${TEST_TYPE}" run
    ;;
  cleanup)
    echo "Cleaning up test data..."
    ${SYSBENCH_CMD} "${TEST_TYPE}" cleanup
    ;;
  *)
    usage
    ;;
esac
