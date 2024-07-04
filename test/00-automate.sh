#!/bin/bash
set -e

# load the script name and path into variables and change to the current directory
TEST_SCRIPTNAME=$(readlink -f "$0")
TEST_SCRIPTPATH=$(dirname "$TEST_SCRIPTNAME")
TEST_BASENAME=$(basename "$0")
cd $TEST_SCRIPTPATH

source test.properties

psql_test="$TEST_PSQL_HOST $TEST_PSQL_ERR_STOP $TEST_PSQL_USER $TEST_PSQL_DB"

echo '-------begin test 01-delete-test-artifacts.sh-------'
./01-delete-test-artifacts.sh
echo '-------end test 01-delete-test-artifacts.sh-------'

echo '-------begin test 02-create-test-artifacts.sh-------'
./02-create-test-artifacts.sh
echo '-------end test 02-create-test-artifacts.sh-------'

echo '-------begin private migration-10-------'
echo "psql_test: $psql_test"
psql $psql_test -f ../private/migration-10-ddl.sql
echo '-------end private migration-10-------'

echo '-------begin private migration-20-------'
echo "psql_test: $psql_test"
psql $psql_test -f ../private/migration-20-func.sql
echo '-------end private migration-20-------'

echo '-------begin private migration-30-------'
echo "psql_test: $psql_test"
psql $psql_test -f ../private/migration-30-public-schema.sql
echo '-------end private migration-30-------'

echo '-------begin migration-30-execute-views-------'
echo "psql_test: $psql_test"
psql $psql_test -c "select $TEST_SCHEMA.create_public_views('$TEST_SCHEMA_API')"
echo '-------end migration-30-execute-views-------'

echo '-------begin migration-30-execute-functions-------'
echo "psql_test: $psql_test"
psql $psql_test -c "select $TEST_SCHEMA.create_public_functions('$TEST_SCHEMA_API')"
echo '-------end migration-30-execute-functions-------'

echo '-------begin private migration-40-------'
echo "psql_test: $psql_test"
psql $psql_test -f ../private/migration-40-template-approval-traditional.sql
echo '-------end private migration-40-------'

echo '-------begin test 10_migration-30-seed.sh-------'
./10_migration-30-seed.sh
echo '-------end test 10_migration-30-seed.sh-------'

echo '-------begin test reload postgrest schema-------'
echo "psql_test: $psql_test"
psql $psql_test -c "NOTIFY pgrst, 'reload schema'"
echo '-------end test reload postgrest schema-------'

echo '-------begin test run sample nushell-------'
sleep 1
echo 'wait for schema refresh...'
sleep 1
echo 'wait for schema refresh...'
sleep 1
../nushell/sample.nu list
echo '-------end test run sample nushell-------'
