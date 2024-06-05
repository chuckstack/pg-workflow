cat this content and copy/execute as you need
source test.properties
psql_test="$TEST_PSQL_HOST $TEST_PSQL_ERR_STOP $TEST_PSQL_USER $TEST_PSQL_DB $TEST_PSQL_VAR_ONLY"
echo "psql_test: $psql_test"
psql $psql_test -c "SELECT gen_random_uuid()"
psql $psql_test -c "SELECT gen_random_uuid()"
psql $psql_test -c "SELECT gen_random_uuid()"
psql $psql_test -c "SELECT gen_random_uuid()"
psql $psql_test -c "SELECT gen_random_uuid()"
psql $psql_test -c "SELECT gen_random_uuid()"
psql $psql_test -c "SELECT gen_random_uuid()"
psql $psql_test -c "SELECT gen_random_uuid()"
psql $psql_test -c "SELECT gen_random_uuid()"
psql $psql_test -c "SELECT gen_random_uuid()"
