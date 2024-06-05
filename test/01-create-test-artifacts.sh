#!/bin/bash
set -e

# load the script name and path into variables and change to the current directory
TEST_SCRIPTNAME=$(readlink -f "$0")
TEST_SCRIPTPATH=$(dirname "$TEST_SCRIPTNAME")
TEST_BASENAME=$(basename "$0")
cd $TEST_SCRIPTPATH

source test.properties

psql_admin="$TEST_PSQL_HOST $TEST_PSQL_ERR_STOP $TEST_PSQL_USER_ADMIN $TEST_PSQL_DB_ADMIN"
psql_test="$TEST_PSQL_HOST $TEST_PSQL_ERR_STOP $TEST_PSQL_USER_ADMIN $TEST_PSQL_DB"
echo "psql_admin: $psql_admin"
echo "psql_test: $psql_test"

#echo '-------begin xxx-------'
#echo '-------end xxx-------'

#SCHEMA_EXISTS=$(psql $psql_test $TEST_PSQL_VAR_ONLY -c "SELECT 1 FROM information_schema.schemata WHERE schema_name = 'private'")
#echo $SCHEMA_EXISTS

#if you get an error that the user or schema does not exist, simply comment out these lines temporarily
psql $psql_test -c " alter default privileges in schema $TEST_SCHEMA revoke select on tables from $TEST_USER; "
psql $psql_test -c " revoke select on all tables in schema $TEST_SCHEMA from $TEST_USER "
psql $psql_test -c " revoke create, usage on schema $TEST_SCHEMA from $TEST_USER "
psql $psql_test -c " revoke all privileges on database $TEST_DB from $TEST_USER "
psql $psql_test -c " revoke connect on database $TEST_DB from $TEST_USER "
psql $psql_test -c " reassign owned by $TEST_USER to $TEST_USER_ADMIN "
psql $psql_test -c " drop owned by $TEST_USER "
psql $psql_admin -c " drop user if exists $TEST_USER "
psql $psql_admin -c " drop database if exists $TEST_DB "


psql $psql_admin -c " create database $TEST_DB "
psql $psql_test -c " create schema $TEST_SCHEMA "
psql $psql_test -c " create role $TEST_USER with login password '$TEST_USER_PASSWORD'"
psql $psql_test -c " grant connect on database $TEST_DB to $TEST_USER "
psql $psql_test -c " grant create, usage on schema $TEST_SCHEMA to $TEST_USER "
psql $psql_test -c " grant select, insert, update, delete on all tables in schema $TEST_SCHEMA to $TEST_USER; "
psql $psql_test -c " alter default privileges in schema $TEST_SCHEMA grant select on tables to $TEST_USER; "
psql $psql_test -c " alter role $TEST_USER set search_path to $TEST_SCHEMA "

