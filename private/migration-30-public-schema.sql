CREATE OR REPLACE FUNCTION create_public_views(public_schema_name TEXT DEFAULT 'api')
RETURNS VOID AS $$
DECLARE
  private_table RECORD;
  public_view_name TEXT;
  table_comment TEXT;
BEGIN
  -- Create the public schema if it doesn't exist
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', public_schema_name);

  -- Iterate over tables starting with 'stack'
  FOR private_table IN (
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = current_schema() AND table_name LIKE 'stack%'
  )
  LOOP
    -- Transform the table name for the public view
    IF private_table.table_name LIKE 'stack_wf_%' THEN
      public_view_name := 'api_wf_' || substring(private_table.table_name, 10);
    ELSE
      public_view_name := 'api_' || substring(private_table.table_name, 7);
    END IF;

    -- Get the comment of the private table
    SELECT obj_description(private_table.table_name::regclass, 'pg_class') INTO table_comment;

    -- Create the pass-through view in the public schema
    EXECUTE format('CREATE OR REPLACE VIEW %I.%I AS SELECT * FROM %I.%I',
                   public_schema_name, public_view_name, current_schema(), private_table.table_name);

    -- Set the comment on the public view
    IF table_comment IS NOT NULL THEN
      EXECUTE format('COMMENT ON VIEW %I.%I IS %L',
                     public_schema_name, public_view_name, table_comment);
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_public_functions(public_schema_name TEXT DEFAULT 'api')
RETURNS VOID AS $$
DECLARE
  private_function RECORD;
  public_function_name TEXT;
  function_comment TEXT;
  function_definition TEXT;
BEGIN
  -- Create the public schema if it doesn't exist
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', public_schema_name);

  -- Iterate over functions starting with 'stack' and not containing 'trigger_func'
  FOR private_function IN (
	SELECT
	    proname,
	    pg_get_function_identity_arguments(oid) AS arg_full,
	    oidvectortypes(proargtypes) AS arg_types,
	    array_to_string(
	        array(
	            SELECT split_part(trim(unnest(string_to_array(pg_get_function_identity_arguments(oid), ','))), ' ', 1)
	        ),
	        ', '
	    ) AS arg_names,
	    prokind,
	    pg_get_function_result(oid) AS return_type
	FROM
	    pg_proc
	WHERE
	    proname LIKE 'stack%' AND proname NOT LIKE '%trigger_func%'
  )
  LOOP
    -- Transform the function name for the public function
    IF private_function.proname LIKE 'stack_wf_%' THEN
      public_function_name := 'api_wf_' || substring(private_function.proname, 10);
    ELSE
      public_function_name := 'api_' || substring(private_function.proname, 7);
    END IF;

    -- Get the comment of the private function
    SELECT obj_description(p.oid, 'pg_proc') INTO function_comment
    FROM pg_proc p
    WHERE p.proname = private_function.proname;

    --RAISE NOTICE 'proname: %', private_function.proname;
    --RAISE NOTICE 'arg_full: %', private_function.arg_full;
    --RAISE NOTICE 'arg_types: %', private_function.arg_types;
    --RAISE NOTICE 'arg_names: %', private_function.arg_names;
    --RAISE NOTICE 'prokind: %', private_function.prokind;
    --RAISE NOTICE 'return_type: %', private_function.return_type;
    --RAISE NOTICE 'function_comment: %', function_comment;
    --RAISE NOTICE '---------------------------------------------------------------------------------';
    
    -- Create the pass-through function in the public schema
    function_definition := format(
      $def$
        CREATE OR REPLACE FUNCTION %I.%I(%s)
        RETURNS %s AS
        $BODY$
        BEGIN
          %s %I(%s);
        END;
        $BODY$
        LANGUAGE plpgsql
        SECURITY DEFINER;
      $def$,
      public_schema_name,
      public_function_name,
      private_function.arg_full,
      private_function.return_type,
      CASE WHEN private_function.return_type <> lower('void') THEN 'RETURN' ELSE 'PERFORM' END,
      private_function.proname,
      private_function.arg_names
    );

    --RAISE NOTICE 'function_definition: %', function_definition;

    -- Execute the function definition
    EXECUTE function_definition;

    -- Set the comment on the public function
    IF function_comment IS NOT NULL THEN
      EXECUTE format('COMMENT ON FUNCTION %I.%I(%s) IS %L',
                     public_schema_name, public_function_name, private_function.arg_types, function_comment);
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
