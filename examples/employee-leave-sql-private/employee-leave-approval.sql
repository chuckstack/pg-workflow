set search_path = private;

CREATE OR REPLACE FUNCTION stack_wf_example_request_create_approval_traditional() RETURNS uuid AS $$
DECLARE
    v_process_uu uuid;
BEGIN
    SELECT 'SOME TEXT' as some_text;
    select stack_wf_template_process_create_approval_traditional(
        false,
        'employee leave'
    );
    

END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION stack_wf_example_request_create_approval_traditional() is ''; 
