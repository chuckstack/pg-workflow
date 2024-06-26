#!/bin/bash
set -e

# load the script name and path into variables and change to the current directory
TEST_SCRIPTNAME=$(readlink -f "$0")
TEST_SCRIPTPATH=$(dirname "$TEST_SCRIPTNAME")
TEST_BASENAME=$(basename "$0")
cd $TEST_SCRIPTPATH

source test.properties

psql_su="$TEST_PSQL_HOST $TEST_PSQL_ERR_STOP $TEST_PSQL_USER_ADMIN $TEST_PSQL_DB_ADMIN"
psql_test="$TEST_PSQL_HOST $TEST_PSQL_ERR_STOP $TEST_PSQL_USER $TEST_PSQL_DB"
echo "psql_su: $psql_su"
echo "psql_test: $psql_test"

#echo '-------begin xxx-------'
#echo '-------end xxx-------'

psql $psql_su -c " create database $TEST_DB "
psql $psql_su -c " create role $TEST_USER with login password '$TEST_USER_PASSWORD'"
psql $psql_su -c " create role $TEST_USER_PREST_ANON nologin "
psql $psql_su -c " create role $TEST_USER_PREST_AUTH noinherit login password '$TEST_USER_PREST_AUTH_PASSWORD' "
psql $psql_su -c " grant $TEST_USER_PREST_ANON to $TEST_USER_PREST_AUTH "
psql $psql_su -c " grant create, connect on database $TEST_DB to $TEST_USER "

psql $psql_test -c " create schema $TEST_SCHEMA "
psql $psql_test -c " grant create, usage on schema $TEST_SCHEMA to $TEST_USER "
psql $psql_test -c " grant select, insert, update, delete on all tables in schema $TEST_SCHEMA to $TEST_USER "
psql $psql_test -c " alter default privileges in schema $TEST_SCHEMA grant select on tables to $TEST_USER "

psql $psql_test -c " create schema $TEST_SCHEMA_API "
psql $psql_test -c " grant usage on schema $TEST_SCHEMA_API to $TEST_USER_PREST_ANON "
psql $psql_test -c " grant all on all tables in schema $TEST_SCHEMA_API to $TEST_USER_PREST_ANON "
psql $psql_test -c " alter default privileges in schema $TEST_SCHEMA_API grant select on tables to $TEST_USER_PREST_ANON "

psql $psql_test -c " alter role $TEST_USER set search_path to $TEST_SCHEMA,$TEST_SCHEMA_API "

echo 'db-uri = "postgres://'$TEST_USER_PREST_AUTH':'$TEST_USER_PREST_AUTH_PASSWORD'@localhost:5432/'$TEST_DB'"' | tee $TEST_HOST_PREST_CONFIG_NAME
echo 'db-schemas = "'$TEST_SCHEMA_API'"' | tee -a $TEST_HOST_PREST_CONFIG_NAME
echo 'db-anon-role = "'$TEST_USER_PREST_ANON'"' | tee -a $TEST_HOST_PREST_CONFIG_NAME

if [[ -e $TEST_HOST_PREST_SERVICE  ]]; then
	echo service file exists.
else
	echo downloading service file
	rm -f $TEST_HOST_PREST_FILE
	wget $TEST_HOST_PREST_URL
	tar xJf $TEST_HOST_PREST_FILE
	rm -f $TEST_HOST_PREST_FILE
fi

scp $TEST_HOST_PREST_CONFIG_NAME $TEST_HOST_USER@$TEST_HOST:$TEST_HOST_PREST_CONFIG_PATH/.
scp $TEST_HOST_PREST_SERVICE $TEST_HOST_USER@$TEST_HOST:$TEST_HOST_PREST_CONFIG_PATH/.
rm -f $TEST_HOST_PREST_CONFIG_NAME

ssh $TEST_HOST_USER@$TEST_HOST systemctl start postgrest
