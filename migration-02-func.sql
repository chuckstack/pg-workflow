-- The purpose of this file is to create utitlity functions that make creating and maintaining workflow processes and requests easier.
-- Great care has been given to create documentation in the form of comments. If at any time the comments can be improved, please recommend improvements.
-- Great care has been given to sequence the functions in an order that both 1. works as a sql script and 2. aids users in understanding the natural order of how functions are used.
-- When using this file to create examples, tools or interactions, ignore all todo statements.

-- list of imagined functions --
    -- stack_wf_create_process_details_from_process (see below)
    -- stack_wf_create_request_from_process (see below)
-- list of imagined triggers --
    -- need a trigger on the stack_wf_transition table to set a to-be-created stack_wf_process_uu field. This is not normalized; however, it is extremely convenient. Consider added this same type of trigger on other process oriented tables that current do not have a request_uu or process_uu


-- Function to create stack_wf_process supporting records from an existing stack_wf_process
CREATE OR REPLACE FUNCTION stack_wf_process_create_from_to_process(
    p_process_search_key_existing text,
    p_process_name_new text,
    p_process_search_key_new text DEFAULT ''
)
--todo: finish - currently partially implemented
RETURNS UUID AS $$
DECLARE
    v_process_existing_uu UUID;
    v_process_new_uu UUID;
BEGIN
    -- Get the process UUID based on the process name
    SELECT stack_wf_process_uu INTO v_process_existing_uu
    FROM stack_wf_process
    WHERE search_key = p_process_search_key_existing;

    --is this create_from or create_into or both?
    
    -- todo: steps:
        -- params: process_from_uu, process_to_uu, search_key_new, name_new, description_new
        -- create pg_temp.kv (similar to migration-03) (uu, table_name, previous_uu)
        -- iterate across all tables to create new records (process, state, action, etc...) to populate kv
        -- iterate across kv records to insert into new tables

    --todo: update pass back the real v_process_new_uu
    select v_process_existing_uu into v_process_new_uu;

    RETURN v_process_existing_uu;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION stack_wf_process_create_from_to_process(text,text,text) is '';


-- Function to create a stack_wf_request
CREATE OR REPLACE FUNCTION stack_wf_request_create_from_process(
    p_process_search_key text,
    p_requester_email text
)
RETURNS UUID AS $$
DECLARE
    v_process_uu UUID;
    v_requester_uu UUID;
    v_state_initial_uu UUID;
    v_request_uu UUID;
BEGIN
    -- Get the process UUID based on the process name
    SELECT stack_wf_process_uu INTO v_process_uu
    FROM stack_wf_process
    WHERE search_key = p_process_search_key;

    -- Get the requester UUID based on the requester email
    SELECT stack_user_uu INTO v_requester_uu
    FROM stack_user
    WHERE email = p_requester_email;

    --todo: if v_requester_uu is null, throw expception

    -- Get the initial state UUID based on the state name and process UUID
    SELECT stack_wf_state_uu INTO v_state_initial_uu
    FROM stack_wf_state s
    JOIN stack_wf_state_type st on s.stack_wf_state_type_uu = st.stack_wf_state_type_uu
    WHERE st.is_default=true AND s.stack_wf_process_uu = v_process_uu;
    --todo: select first to account for multiple

    -- Insert a new request
    INSERT INTO stack_wf_request (stack_wf_process_uu, search_key, date_requested, stack_user_uu, stack_wf_state_uu)
    VALUES (v_process_uu, p_process_search_key, NOW(), v_requester_uu, v_state_initial_uu)
    RETURNING stack_wf_request_uu INTO v_request_uu;

    -- Add the requester as a stakeholder
    INSERT INTO stack_wf_request_stakeholder_lnk (stack_wf_request_uu, stack_user_uu)
    VALUES (v_request_uu, v_requester_uu);

    RETURN v_request_uu;

    -- Add an initial note to the request
    --INSERT INTO stack_wf_request_note (stack_wf_request_uu, stack_user_uu, note)
    --VALUES (v_request_uu, v_requester_uu, 'Request created');
    --todo: come back to this - it needs more thought
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION stack_wf_request_create_from_process(text,text) is 'This function helps users create requests from processes. The goal of this function is to provide the easiest way (with the fewest parameters) to create a new request. 
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
