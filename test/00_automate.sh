#!/bin/bash
set -e
psql_args="-h 10.178.252.246 -v ON_ERROR_STOP=on -U adempiere" # -d idempiere db_20240527_01

echo '-------begin drop and create-------'
psql $psql_args -d idempiere -f test/05_drop_database_create.sql
echo '-------end drop and create-------'

echo '-------begin migration-01-------'
psql $psql_args -d db_20240527_01 -f migration-01-ddl.sql
echo '-------end migration-01-------'

echo '-------begin migration-02-------'
psql $psql_args -d db_20240527_01 -f migration-02-func.sql
echo '-------end migration-02-------'

echo '-------begin migration-03-------'
psql $psql_args -d db_20240527_01 -f migration-03-template-approval-traditional.sql
echo '-------end migration-03-------'

echo '-------begin test-------'
psql $psql_args -d db_20240527_01 -f test/migration-03-seed.sql
echo '-------end test-------'

