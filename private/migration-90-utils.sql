--two ways to reference tables:
-- pg_class (tables, views, etc..) - deep psql internal
-- information_schema.tables - ansi standard and more user friendly
-- see psql-trigger-function-table-name-change-log* in aichat/session

-- get the function name, return type and parameters
SELECT r.routine_name AS function_name,
       r.data_type AS return_type,
       string_agg(p.parameter_name || ' ' || p.data_type, ', ' ORDER BY p.
ordinal_position) AS parameter
FROM information_schema.routines r
LEFT JOIN information_schema.parameters p ON r.specific_name = p.specific_name
WHERE r.routine_type = 'FUNCTION' and r.routine_name = 'add_months'
GROUP BY r.routine_name, r.data_type
;

-- get the function comments
SELECT d.description
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
LEFT JOIN pg_description d ON p.oid = d.objoid
WHERE p.proname = 'add_months';
