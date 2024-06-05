#!/bin/bash
set -e

# load the script name and path into variables and change to the current directory
TEST_SCRIPTNAME=$(readlink -f "$0")
TEST_SCRIPTPATH=$(dirname "$TEST_SCRIPTNAME")
TEST_BASENAME=$(basename "$0")
cd $TEST_SCRIPTPATH

source test.properties

psql_test="$TEST_PSQL_HOST $TEST_PSQL_ERR_STOP $TEST_PSQL_USER $TEST_PSQL_DB"

echo '-------begin 01-create-test-artifacts.sh-------'
./01-create-test-artifacts.sh
echo '-------end 01-create-test-artifacts.sh-------'

echo '-------begin migration-01-------'
echo "psql_test: $psql_test"
psql $psql_test -f ../migration-01-ddl.sql
echo '-------end migration-01-------'

echo '-------begin migration-02-------'
echo "psql_test: $psql_test"
psql $psql_test -f ../migration-02-func.sql
echo '-------end migration-02-------'

echo '-------begin migration-03-------'
echo "psql_test: $psql_test"
psql $psql_test -f ../migration-03-template-approval-traditional.sql
echo '-------end migration-03-------'

echo '-------begin 10_migration-03-seed.sh-------'
./10_migration-03-seed.sh
echo '-------end 10_migration-03-seed.sh-------'
