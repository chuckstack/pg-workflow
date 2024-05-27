-- The purpose of this file is to populate a newly created database is the artifacts needed to create, maintain and execute workflows.
-- Great care has been given to create documentation in the form of table comments. If at any time the comments can be improved, please recommend improvements.
-- Great care has been given to sequence the tables in an order that both 1. works as a sql script and 2. aids users in understanding the natural order of how records are created.
-- When using this file to create examples, tools or interactions, ignore all todo statements.


set search_path = private;

-- Function to create a chuboe_request
CREATE OR REPLACE FUNCTION create_chuboe_request(
    p_process_name VARCHAR,
    p_title VARCHAR,
    p_requester_email VARCHAR,
    p_initial_state_name VARCHAR
)
RETURNS VOID AS $$
DECLARE
    v_process_uu UUID;
    v_requester_uu UUID;
    v_initial_state_uu UUID;
    v_request_uu UUID;
BEGIN
    -- Get the process UUID based on the process name
    SELECT chuboe_process_uu INTO v_process_uu
    FROM chuboe_process
    WHERE name = p_process_name;

    -- Get the requester UUID based on the requester email
    SELECT chuboe_user_uu INTO v_requester_uu
    FROM chuboe_user
    WHERE email = p_requester_email;

    -- Get the initial state UUID based on the state name and process UUID
    SELECT chuboe_state_uu INTO v_initial_state_uu
    FROM chuboe_state
    WHERE name = p_initial_state_name AND chuboe_process_uu = v_process_uu;

    -- Insert a new request
    INSERT INTO chuboe_request (chuboe_process_uu, title, date_requested, chuboe_user_uu, user_name, chuboe_current_state_uu)
    VALUES (v_process_uu, p_title, NOW(), v_requester_uu, (SELECT CONCAT(first_name, ' ', last_name) FROM chuboe_user WHERE chuboe_user_uu = v_requester_uu), v_initial_state_uu)
    RETURNING chuboe_request_uu INTO v_request_uu;

    -- Add the requester as a stakeholder
    INSERT INTO chuboe_request_stakeholder_lnk (chuboe_request_uu, chuboe_user_uu)
    VALUES (v_request_uu, v_requester_uu);

    -- Add an initial note to the request
    INSERT INTO chuboe_request_note (chuboe_request_uu, chuboe_user_uu, note)
    VALUES (v_request_uu, v_requester_uu, 'Request created');
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION create_chuboe_request(varchar,varchar,varchar,varchar) is 'This function helps users create requests from processes. The goal of this function is to provide the easiest way (with the fewest requirements) to create a new request';
--todo:make the following changes:
---request user_name needs to go away
---needs a default state
---title should be optional - auto-created if not specified


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
