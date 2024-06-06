-- The purpose of this file is to create utitlity functions that make creating and maintaining workflow processes and requests easier.
-- Great care has been given to create documentation in the form of comments. If at any time the comments can be improved, please recommend improvements.
-- Great care has been given to sequence the functions in an order that both 1. works as a sql script and 2. aids users in understanding the natural order of how functions are used.
-- When using this file to create examples, tools or interactions, ignore all todo statements.

-- list of imagined functions --
    -- stack_wf_create_process_details_from_process (see below)
    -- stack_wf_create_request_from_process (see below)
-- list of imagined triggers --
    -- need a trigger on the stack_wf_transition table to set a to-be-created stack_wf_process_uu field. This is not normalized; however, it is extremely convenient. Consider added this same type of trigger on other process oriented tables that current do not have a request_uu or process_uu

-- Function to list request data
CREATE OR REPLACE FUNCTION stack_wf_request_get_data(
    p_request_uu uuid
)
RETURNS text[] AS $$
DECLARE
    v_data text[];
BEGIN
    select array_agg(concat_ws(': ', name, value)) into v_data
    from (
        select d.name, d.value
        from stack_wf_request_data d
        where d.stack_wf_request_uu = p_request_uu
        order by d.created desc
    ) t;
    return v_data;
    
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION stack_wf_request_get_data(uuid) is '';

-- Function to list request last x notes
CREATE OR REPLACE FUNCTION stack_wf_request_get_notes(
    p_request_uu uuid,
    p_note_count integer
)
RETURNS text[] AS $$
DECLARE
    v_notes text[];
BEGIN
    select array_agg(concat_ws(' by: ', note, name)) into v_notes
    from (
        select n.note, concat_ws(' ', u.first_name, u.last_name) as name
        from stack_wf_request_note n
        join stack_user u on n.stack_user_uu = n.stack_user_uu
        where n.stack_wf_request_uu = p_request_uu
        order by n.created desc
        limit p_note_count
    ) t;
    return v_notes;
    
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION stack_wf_request_get_notes(uuid,integer) is '';

-- Function to create stack_wf_process supporting records from an existing stack_wf_process
CREATE OR REPLACE FUNCTION stack_wf_process_create_from_to_process(
    p_process_existing_uu uuid,
    p_process_name_new text,
    p_process_search_key_new text DEFAULT ''
)
--todo: finish - currently partially implemented
RETURNS UUID AS $$
DECLARE
    v_process_new_uu UUID;
BEGIN
    
    -- todo: steps:
        -- params: process_from_uu, process_to_uu, search_key_new, name_new, description_new
        -- create pg_temp.kv (similar to migration-03) (uu, table_name, previous_uu)
        -- iterate across all tables to create new records (process, state, action, etc...) to populate kv
        -- iterate across kv records to insert into new tables

    --todo: update pass back the real v_process_new_uu
    select p_process_existing_uu into v_process_new_uu;

    RETURN v_process_new_uu;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION stack_wf_process_create_from_to_process(uuid,text,text) is '';


-- Function to create a stack_wf_request
CREATE OR REPLACE FUNCTION stack_wf_request_create_from_process(
    p_process_uu uuid,
    p_requester_uu uuid
)
RETURNS UUID AS $$
DECLARE
    v_state_initial_uu uuid;
    v_resolution_initial_uu uuid;
    v_request_uu uuid;
BEGIN
    --todo: if any parameter is null, throw excpetion

    -- Get the initial state UUID based on the process UUID
    SELECT stack_wf_state_uu INTO v_state_initial_uu
    FROM stack_wf_state s
    JOIN stack_wf_state_type st on s.stack_wf_state_type_uu = st.stack_wf_state_type_uu
    WHERE st.is_default=true AND s.stack_wf_process_uu = p_process_uu;
    --todo: select first to account for multiple

    -- Get the initial resolution UUID based on the process UUID
    SELECT stack_wf_resolution_uu INTO v_resolution_initial_uu
    FROM stack_wf_resolution r
    JOIN stack_wf_resolution_type st on r.stack_wf_resolution_type_uu = st.stack_wf_resolution_type_uu
    WHERE st.is_default=true AND r.stack_wf_process_uu = p_process_uu;
    --todo: select first to account for multiple

    --todo: fix "some text for now" hard coded variable
    -- Insert a new request
    INSERT INTO stack_wf_request (stack_wf_process_uu, search_key, date_requested, stack_user_uu, stack_wf_state_uu, stack_wf_resolution_uu)
    VALUES (p_process_uu, 'some text for now', NOW(), p_requester_uu, v_state_initial_uu, v_resolution_initial_uu)
    RETURNING stack_wf_request_uu INTO v_request_uu;

    -- Add the requester as a stakeholder
    INSERT INTO stack_wf_request_stakeholder_lnk (stack_wf_request_uu, stack_user_uu)
    VALUES (v_request_uu, p_requester_uu);

    RETURN v_request_uu;

    -- Add an initial note to the request
    --INSERT INTO stack_wf_request_note (stack_wf_request_uu, stack_user_uu, note)
    --VALUES (v_request_uu, p_requester_uu, 'Request created');
    --todo: come back to this - it needs more thought
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION stack_wf_request_create_from_process(uuid,uuid) is 'This function helps users create requests from processes. The goal of this function is to provide the easiest way (with the fewest parameters) to create a new request. 
p_process_search_key is the process.search_key value. 
p_requester_email is the user.email who is requesting the new instance. 
';


--todo: consider something like the following:
---- Trigger function to log request creation
--CREATE OR REPLACE FUNCTION log_request_creation()
--RETURNS TRIGGER AS $$
--BEGIN
--    -- Insert a record into the stack_wf_request_action_log table
--    INSERT INTO stack_wf_request_action_log (stack_wf_request_uu, stack_wf_action_uu, stack_wf_transition_uu, is_active, is_processed)
--    VALUES (NEW.stack_wf_request_uu, NULL, NULL, true, false);
--
--    RETURN NEW;
--END;
--$$ LANGUAGE plpgsql;
--
---- Trigger to log request creation
--CREATE TRIGGER tr_log_request_creation
--AFTER INSERT ON stack_wf_request
--FOR EACH ROW
--EXECUTE FUNCTION log_request_creation();

--Issues with the above:
---does not execute because of non-null constraint
---insert statement hard-codes null on important columns
---needs more thought...
