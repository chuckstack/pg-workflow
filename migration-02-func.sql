-- The purpose of this file is to create utitlity functions that make creating and maintaining workflow processes and requests easier.
-- Great care has been given to create documentation in the form of comments. If at any time the comments can be improved, please recommend improvements.
-- Great care has been given to sequence the functions in an order that both 1. works as a sql script and 2. aids users in understanding the natural order of how functions are used.
-- When using this file to create examples, tools or interactions, ignore all todo statements.

-- list of imagined functions --
    -- chuboe_create_process_details_from_process (see below)
    -- chuboe_create_request_from_process (see below)
-- list of imagined triggers --
    -- here...

set search_path = private;

-- Function to create chuboe_process supporting records from an existing chuboe_process
CREATE OR REPLACE FUNCTION chuboe_create_process_details_from_process(
    p_process_search_key_existing VARCHAR,
    p_process_name_new VARCHAR,
    p_process_search_key_new VARCHAR DEFAULT ''
)
--todo: finish - currently partially implemented
RETURNS UUID AS $$
DECLARE
    v_process_existing_uu UUID;
    v_process_new_uu UUID;
BEGIN
    -- Get the process UUID based on the process name
    SELECT chuboe_process_uu INTO v_process_existing_uu
    FROM chuboe_process
    WHERE search_key = p_process_search_key_existing;
    
    --todo: execute migration-03-seed.sql before completing this function
    --todo:copy over records (and their link table records)
      -- state
      -- activity
      -- action
      -- target
      -- resolution
      -- transition


    --todo: update pass back the real v_process_new_uu
    select v_process_existing_uu into v_process_new_uu;

    RETURN v_process_existing_uu;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION chuboe_create_process_details_from_process(varchar,varchar,varchar) is '';


-- Function to create a chuboe_request
CREATE OR REPLACE FUNCTION chuboe_create_request_from_process(
    p_process_search_key VARCHAR,
    p_requester_email VARCHAR
)
RETURNS UUID AS $$
DECLARE
    v_process_uu UUID;
    v_requester_uu UUID;
    v_state_initial_uu UUID;
    v_request_uu UUID;
BEGIN
    -- Get the process UUID based on the process name
    SELECT chuboe_process_uu INTO v_process_uu
    FROM chuboe_process
    WHERE search_key = p_process_search_key;

    -- Get the requester UUID based on the requester email
    SELECT chuboe_user_uu INTO v_requester_uu
    FROM chuboe_user
    WHERE email = p_requester_email;

    -- Get the initial state UUID based on the state name and process UUID
    SELECT chuboe_state_uu INTO v_state_initial_uu
    FROM chuboe_state s
    JOIN chuboe_state_type st on s.chuboe_state_type_uu = st.chuboe_state_type_uu
    WHERE st.is_default=true AND s.chuboe_process_uu = v_process_uu;
    --todo: select first to account for multiple

    -- Insert a new request
    INSERT INTO chuboe_request (chuboe_process_uu, search_key, date_requested, chuboe_user_uu, chuboe_state_uu)
    VALUES (v_process_uu, p_process_search_key, NOW(), v_requester_uu, v_state_initial_uu)
    RETURNING chuboe_request_uu INTO v_request_uu;

    -- Add the requester as a stakeholder
    INSERT INTO chuboe_request_stakeholder_lnk (chuboe_request_uu, chuboe_user_uu)
    VALUES (v_request_uu, v_requester_uu);

    RETURN v_request_uu;

    -- Add an initial note to the request
    --INSERT INTO chuboe_request_note (chuboe_request_uu, chuboe_user_uu, note)
    --VALUES (v_request_uu, v_requester_uu, 'Request created');
    --todo: come back to this - it needs more thought
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION chuboe_create_request_from_process(varchar,varchar) is 'This function helps users create requests from processes. The goal of this function is to provide the easiest way (with the fewest parameters) to create a new request. 
p_process_search_key is the process.search_key value. 
p_requester_email is the user.email who is requesting the new instance. 
';


--todo: consider something like the following:
---- Trigger function to log request creation
--CREATE OR REPLACE FUNCTION log_request_creation()
--RETURNS TRIGGER AS $$
--BEGIN
--    -- Insert a record into the chuboe_request_action_log table
--    INSERT INTO chuboe_request_action_log (chuboe_request_uu, chuboe_action_uu, chuboe_transition_uu, is_active, is_processed)
--    VALUES (NEW.chuboe_request_uu, NULL, NULL, true, false);
--
--    RETURN NEW;
--END;
--$$ LANGUAGE plpgsql;
--
---- Trigger to log request creation
--CREATE TRIGGER tr_log_request_creation
--AFTER INSERT ON chuboe_request
--FOR EACH ROW
--EXECUTE FUNCTION log_request_creation();

--Issues with the above:
---does not execute because of non-null constraint
---insert statement hard-codes null on important columns
---needs more thought...
