# misc notes about sql

## setting and reading json column comments/description

COMMENT ON COLUMN wf_process.name IS '{"column_label": "Name", "column_description": "Name describing the record"}';

SELECT
    pg_catalog.col_description(c.oid, col.ordinal_position::int)::json->>'column_label' as column_label
FROM
    information_schema.columns col
JOIN
    pg_catalog.pg_class c ON c.relname = col.table_name
JOIN
    pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE
    col.table_name = 'wf_process'
    and col.column_name = 'name'
ORDER BY
    col.ordinal_position;
