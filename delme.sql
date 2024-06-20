SELECT
    proname,
    pg_get_function_identity_arguments(oid) AS arg_full,
    oidvectortypes(proargtypes) AS arg_types,
    array_to_string(
        array(
            SELECT split_part(trim(unnest(string_to_array(pg_get_function_identity_arguments(oid), ','))), ' ', 1)
        ),
        ', '
    ) AS arg_variables,
    prokind,
    pg_get_function_result(oid) AS return_type
FROM
    pg_proc
WHERE
    proname LIKE 'stack%' AND proname NOT LIKE '%trigger_func%';
