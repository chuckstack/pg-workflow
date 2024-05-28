-- the purpose of this file is to provide records that help kickstart process and request creation.

-- typical process
  -- state
  -- activity
  -- action
  -- target
  -- resolution
  -- transition
  -- group?

set search_path = private;

------------------------------------
-- approval process workflow seed --
------------------------------------

CREATE OR REPLACE FUNCTION chuboe_wf_template_create_approval() RETURNS uuid AS $$
DECLARE
    v_process_uu uuid;
BEGIN
    set search_path = private;
    
    -- Create the temporary table - state, action and resolution
    -- note: this temp table name is hard-coded; therefore, it might not be concurrent safe.
    CREATE TEMPORARY TABLE chuboe_wf_template_temp_01(
        search_key varchar(255),
        name varchar(255),
        description varchar(255) 
    );
    
    -- Create the temporary table - transition
    -- note: this temp table name is hard-coded; therefore, it might not be concurrent safe.
    CREATE TEMPORARY TABLE chuboe_wf_template_temp_02_transition(
        state_from_search_key varchar(255),
        state_from_uuid uuid,
        state_to_search_key varchar(255),
        state_to_uuid uuid,
        resolution_to_search_key varchar(255),
        resolution_to_uuid uuid,
        chuboe_process_uu uuid
    );
 
    --------------------------------
    -- create the process
    --------------------------------
    INSERT INTO chuboe_process (search_key, name, is_template, description)
    VALUES ('sample_approval', 'Sample approval process', true, 'Template/example of an approval process.')
    RETURNING chuboe_process_uu INTO v_process_uu;
  
    --------------------------------
    -- create the process states
    --------------------------------
    -- Define state records to be inserted
  	-- position 1: search key from state_type
        -- position 2: to_be name of the process state record
        -- position 3: to_be description of the process state record
    INSERT INTO chuboe_wf_template_temp_01 values
        ('started', 'New approval request', 'New xxx request'),
        ('submitted', 'Approval request submitted', 'xxx request submitted to manager'),
        ('replied', 'Approval request replied', 'Manager replied to xxx request'),
        ('finalized', 'Approval request final closed', 'xxx request final closed')
    ;
  
    -- note: the insert statement keeps search_key from the state_type. Stating this because below dependencies on the state search key.
    INSERT INTO chuboe_state (chuboe_state_type_uu, chuboe_process_uu, search_key, name, description)
        select st.chuboe_state_type_uu, v_process_uu, st.search_key, coalesce(tt.name,st.name), coalesce(tt.description,st.description)
        from chuboe_state_type st
        join chuboe_wf_template_temp_01 tt on st.search_key = tt.search_key
    ;
  
    truncate chuboe_wf_template_temp_01;
  
    --------------------------------
    -- create the process actions
    --------------------------------
    -- Define action records to be inserted
  	-- position 1: search key from action_type
        -- position 2: to_be name of the process action record
        -- position 3: to_be description of the process action record
    INSERT INTO chuboe_wf_template_temp_01 values
        ('approve', 'Approve Request', 'Manager approves the xxx request'),
        ('deny', 'Deny Request', 'Manager denies the xxx request')
    ;
  
    -- note: the insert statement keeps search_key from the action_type. Stating this because below dependencies on the action search key.
    INSERT INTO chuboe_action (chuboe_action_type_uu, chuboe_process_uu, search_key, name, description)
        select cat.chuboe_action_type_uu, v_process_uu, cat.search_key, coalesce(tt.name,cat.name), coalesce(tt.description,cat.description)
        from chuboe_action_type cat
        join chuboe_wf_template_temp_01 tt on cat.search_key = tt.search_key
    ;
  
    truncate chuboe_wf_template_temp_01;
    
    --------------------------------
    -- create the process resolution
    --------------------------------
    -- Define resolution records to be inserted
  	-- position 1: search key from resolution_type
        -- position 2: to_be name of the process resolution record
        -- position 3: to_be description of the process resolution record
    INSERT INTO chuboe_wf_template_temp_01 values
        ('none', null, null),
        ('approved', null, null),
        ('denied', null, null)
    ;
  
    INSERT INTO chuboe_resolution (chuboe_resolution_type_uu, chuboe_process_uu, search_key, name, description)
        select crt.chuboe_resolution_type_uu, v_process_uu, crt.search_key, coalesce(tt.name,crt.name), coalesce(tt.description,crt.description)
        from chuboe_resolution_type crt
        join chuboe_wf_template_temp_01 tt on crt.search_key = tt.search_key
    ;
  
    truncate chuboe_wf_template_temp_01;
    

    -- added for quick visual reference - delme
    --CREATE TEMPORARY TABLE chuboe_wf_template_temp_02_transition(
    --    state_from_search_key varchar(255),
    --    state_from_uuid uuid,
    --    state_to_search_key varchar(255),
    --    state_to_uuid uuid,
    --    resolution_to_search_key varchar(255),
    --    resolution_to_uuid uuid,
    --    chuboe_process_uu uuid
    --);

    ---- todo: need to understand if resolution needs to be mapped here? I believe no...
    ----------------------------------
    ---- create the process transitions
    ----------------------------------
    ---- Define resolution records to be inserted
  	---- position 1: search key for state_from
    --    -- position 2: search key for state_to
    --    -- position 3: search key for resolution_to
    --INSERT INTO chuboe_wf_template_temp_02_transition (state_from_search_key, state_to_search_key, resolution_to_search_key) values
    --    ('started', 'submitted', null),
    --    ('submitted', 'replied', 'approved'),
    --    ('submitted', 'replied', 'denied'),
    --    ('denied', null, null)
    --;
  
    -- todo: finish
    --INSERT INTO chuboe_xxx (chuboe_resolution_type_uu, chuboe_process_uu, search_key, name, description)
    --    select crt.chuboe_resolution_type_uu, v_process_uu, crt.search_key, coalesce(tt.name,crt.name), coalesce(tt.description,crt.description)
    --    from chuboe_resolution_type crt
    --    join chuboe_wf_template_temp_02_transition tt on crt.search_key = tt.search_key
    --;
  
    truncate chuboe_wf_template_temp_02_transition;
    

    -- Perform some operations on the temporary table
    --EXECUTE format('UPDATE %I SET age = age + 1 WHERE name LIKE $1', temp_table_name)
    --USING 'John%';
  
    -- Select data from the temporary table
    --EXECUTE format('SELECT * FROM %I', temp_table_name);
  
    RETURN v_process_uu;
  
    -- The temporary table will be automatically dropped when the function ends
END;
$$ LANGUAGE plpgsql;


--INSERT INTO chuboe_process (chuboe_process_uu, search_key, name, is_template, description)
--VALUES ('414e5d60-4262-4998-b1b4-286840bfe397', 'sample_approval', 'Sample approval process', true, 'Template/example of an approval process.');
--
---- add states - note that each insert statment creates a unique state name and description to match the workflow use case
---- todo: create a better data structure to visualize the mapping between the state_type.search_key and the resulting state name and description.
--INSERT INTO chuboe_state (chuboe_state_type_uu, chuboe_process_uu, search_key, name, description)
--select chuboe_state_type_uu, '414e5d60-4262-4998-b1b4-286840bfe397', search_key, 'New approval request', 'New request for xxx' 
--from chuboe_state_type
--where search_key = 'started'
--;
--INSERT INTO chuboe_state (chuboe_state_type_uu, chuboe_process_uu, search_key, name, description)
--select chuboe_state_type_uu, '414e5d60-4262-4998-b1b4-286840bfe397', search_key, 'Approval request submitted', 'Request submitted to manager for xxx' 
--from chuboe_state_type
--where search_key = 'submitted'
--;
--INSERT INTO chuboe_state (chuboe_state_type_uu, chuboe_process_uu, search_key, name, description)
--select chuboe_state_type_uu, '414e5d60-4262-4998-b1b4-286840bfe397', search_key, 'Approval request replied', 'Manager replied to request for xxx - see resolution' 
--from chuboe_state_type
--where search_key = 'replied'
--;
--INSERT INTO chuboe_state (chuboe_state_type_uu, chuboe_process_uu, search_key, name, description)
--select chuboe_state_type_uu, '414e5d60-4262-4998-b1b4-286840bfe397', search_key, 'Approval request final closed', 'Request for xxx final closed' 
--from chuboe_state_type
--where search_key = 'finalized'
--;


--WITH my_state as (
--    select *
--    from chuboe_state_type
--) 
--INSERT INTO chuboe_state (chuboe_state_type_uu, chuboe_process_uu, search_key, name, description)
--select chuboe_state_type_uu, '414e5d60-4262-4998-b1b4-286840bfe397', search_key, name, name || ' - give me a better name and desc'
--from my_state
--;
