CREATE OR REPLACE FUNCTION create_public_views(public_schema_name TEXT)
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
