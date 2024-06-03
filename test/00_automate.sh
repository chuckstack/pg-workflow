echo '-------begin drop and create-------'
psql -h 10.178.252.246 -d idempiere -U adempiere -f test/05_drop_database_create.sql
echo '-------end drop and create-------'
echo '-------begin migration-01-------'
psql -h 10.178.252.246 -d db_20240527_01 -U adempiere -f migration-01-ddl.sql
echo '-------end migration-01-------'
echo '-------begin migration-02-------'
psql -h 10.178.252.246 -d db_20240527_01 -U adempiere -f migration-02-func.sql
echo '-------end migration-02-------'
echo '-------begin migration-03-------'
psql -h 10.178.252.246 -d db_20240527_01 -U adempiere -f migration-03-template-approval-traditional.sql
echo '-------end migration-03-------'
echo '-------begin test-------'
psql -h 10.178.252.246 -d db_20240527_01 -U adempiere -f test/migration-03-seed.sql
echo '-------end test-------'

