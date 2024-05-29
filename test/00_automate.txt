psql -h 10.178.252.246 -d idempiere -U adempiere -f test/05_drop_database_create.sql
psql -h 10.178.252.246 -d db_20240527_01 -U adempiere -f migration-01-ddl.sql -f migration-02-func.sql -f migration-03-seed.sql
psql -h 10.178.252.246 -d db_20240527_01 -U adempiere -f test/migration-03-seed.sql

