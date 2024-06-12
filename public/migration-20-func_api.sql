CREATE FUNCTION api_boolean_yes_no(()
RETURNS  AS
$BODY$
BEGIN
  RETURN wf_private.stack_boolean_yes_no(();
END;
$BODY$
LANGUAGE plpgsql
SECURITY DEFINER;
COMMENT ON FUNCTION api_boolean_yes_no(() is 'Function for convenience to convert boolean into Yes/No text';

CREATE FUNCTION api_boolean_open_close(()
RETURNS  AS
$BODY$
BEGIN
  RETURN wf_private.stack_boolean_open_close(();
END;
$BODY$
LANGUAGE plpgsql
SECURITY DEFINER;
COMMENT ON FUNCTION api_boolean_open_close(() is 'Function for convenience to convert boolean into Open/Closed text';

CREATE FUNCTION api_wf_request_get_activity_history(()
RETURNS  AS
$BODY$
BEGIN
  RETURN wf_private.stack_wf_request_get_activity_history(();
END;
$BODY$
LANGUAGE plpgsql
SECURITY DEFINER;
COMMENT ON FUNCTION api_wf_request_get_activity_history(() is 'Function to list request activity history';

CREATE FUNCTION api_wf_request_get_actions(()
RETURNS  AS
$BODY$
BEGIN
  RETURN wf_private.stack_wf_request_get_actions(();
END;
$BODY$
LANGUAGE plpgsql
SECURITY DEFINER;
COMMENT ON FUNCTION api_wf_request_get_actions(() is 'Function to list request next actions';

CREATE FUNCTION api_wf_request_get_data(()
RETURNS  AS
$BODY$
BEGIN
  RETURN wf_private.stack_wf_request_get_data(();
END;
$BODY$
LANGUAGE plpgsql
SECURITY DEFINER;
COMMENT ON FUNCTION api_wf_request_get_data(() is 'Function to list request data';

CREATE FUNCTION api_wf_request_get_notes(()
RETURNS  AS
$BODY$
BEGIN
  RETURN wf_private.stack_wf_request_get_notes(();
END;
$BODY$
LANGUAGE plpgsql
SECURITY DEFINER;
COMMENT ON FUNCTION api_wf_request_get_notes(() is 'Function to list request last x notes';

CREATE FUNCTION api_wf_process_create_from_to_process(()
RETURNS  AS
$BODY$
BEGIN
  RETURN wf_private.stack_wf_process_create_from_to_process(();
END;
$BODY$
LANGUAGE plpgsql
SECURITY DEFINER;
COMMENT ON FUNCTION api_wf_process_create_from_to_process(() is 'Function to create stack_wf_process supporting records from an existing stack_wf_process';

CREATE FUNCTION api_wf_request_create_from_process(()
RETURNS  AS
$BODY$
BEGIN
  RETURN wf_private.stack_wf_request_create_from_process(();
END;
$BODY$
LANGUAGE plpgsql
SECURITY DEFINER;

CREATE FUNCTION api_wf_request_do_action(()
RETURNS  AS
$BODY$
BEGIN
  RETURN wf_private.stack_wf_request_do_action(();
END;
$BODY$
LANGUAGE plpgsql
SECURITY DEFINER;
COMMENT ON FUNCTION api_wf_request_do_action(() is 'This function performs the action linked to the supplied transition.';

