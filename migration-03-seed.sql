-- the purpose of this file is to provide records that help kickstart process and request creation.

-- things that you might want to create when generating a new process
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
    
    --------------------------------
    -- create the temporary tables
    --------------------------------
    -- todo: these temp table names are hard-coded; therefore, it might not be concurrent safe. Need to research.
    
    -- state, action and resolution
    CREATE TEMPORARY TABLE chuboe_wf_template_temp_01(
        search_key varchar(255),
        name varchar(255),
        description varchar(255) 
    );
    
    -- transition
    CREATE TEMPORARY TABLE chuboe_wf_template_temp_02_transition(
        temp_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(), --allows us to pre-determine the id for future purposes
        state_from_search_key varchar(255),
        state_from_uu uuid,
        state_to_search_key varchar(255),
        state_to_uu uuid,
        resolution_to_search_key varchar(255),
        resolution_to_uu uuid,
        chuboe_process_uu uuid
    );
 
    -- acton-transition
    CREATE TEMPORARY TABLE chuboe_wf_template_temp_03_action_transition(
        temp_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        action_search_key varchar(255),
        action_uu uuid,
        chuboe_transition_uu uuid,
        resolution_search_key varchar(255),
        resolution_uu uuid,
        chuboe_process_uu uuid
    );
 
    --------------------------------
    -- create the process
    --------------------------------
    INSERT INTO chuboe_process (search_key, name, is_template, description, chuboe_process_type_uu)
    VALUES ('sample_approval', 'Sample approval process', true, 'Template/example of an approval process.', 'd4d85948-ee7e-4880-8269-e5cc85b3f2fe')
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
        ('submit', 'Submit Request', 'Employee submits the xxx request'),
        ('approve', 'Approve Request', 'Manager approves the xxx request'),
        ('more-info', 'Request More Info', 'Manager needs more informationo to approve  xxx request'),
        ('deny', 'Deny Request', 'Manager denies the xxx request'),
        ('close', 'Close Request', 'Employee closes the xxx request as acknowledgement of the response')
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
        ('pending', null, null),
        ('denied', null, null)
    ;
  
    INSERT INTO chuboe_resolution (chuboe_resolution_type_uu, chuboe_process_uu, search_key, name, description)
        select crt.chuboe_resolution_type_uu, v_process_uu, crt.search_key, coalesce(tt.name,crt.name), coalesce(tt.description,crt.description)
        from chuboe_resolution_type crt
        join chuboe_wf_template_temp_01 tt on crt.search_key = tt.search_key
    ;
  
    truncate chuboe_wf_template_temp_01;
    

    --------------------------------
    -- create the process transitions
    --------------------------------
    -- Define resolution records to be inserted
  	-- position 1: uuid for future reference - will become the transition uuid 
        -- position 3: search key for state_from
        -- position 3: search key for state_to
        -- position 4: search key for resolution_to
    INSERT INTO chuboe_wf_template_temp_02_transition (temp_uu,state_from_search_key, state_to_search_key, resolution_to_search_key) values
        ('affda00d-e32a-4c67-82e0-236d08e426a7', 'started', 'submitted', null),
        ('f35840c2-dabf-4052-ae58-a534692ce9e7', 'submitted', 'replied', null),
        ('192dcffc-7c06-484c-82cd-3587b0b0cbcf', 'submitted', 'started', null), --handles the case when more information is needed
        ('4603b103-0bbd-4a36-a62f-f306353db2f1', 'replied', 'finalized', null)
    ;

    UPDATE chuboe_wf_template_temp_02_transition t
    set state_from_uu = x.chuboe_state_uu
    from chuboe_state x
    where x.chuboe_process_uu = v_process_uu
      and x.search_key = t.state_from_search_key
    ;
    
    UPDATE chuboe_wf_template_temp_02_transition t
    set state_to_uu = x.chuboe_state_uu
    from chuboe_state x
    where x.chuboe_process_uu = v_process_uu
      and x.search_key = t.state_to_search_key
    ;

    UPDATE chuboe_wf_template_temp_02_transition t
    set resolution_to_uu = x.chuboe_resolution_uu
    from chuboe_resolution x
    where x.chuboe_process_uu = v_process_uu
      and x.search_key = t.resolution_to_search_key
    ;

    INSERT INTO chuboe_transition (chuboe_transition_uu, chuboe_state_current_uu, chuboe_state_next_uu, chuboe_resolution_uu)
        select t.temp_uu, t.state_from_uu, t.state_to_uu, t.resolution_to_uu
        from chuboe_wf_template_temp_02_transition t
    ;
  
    truncate chuboe_wf_template_temp_02_transition;
    

    ---- delme - added for quick reference
    ---- acton-transition
    --CREATE TEMPORARY TABLE chuboe_wf_template_temp_03_action_transition(
    --    temp_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    --    action_search_key varchar(255),
    --    action_uu uuid,
    --    chuboe_transition_uu,
    --    resolution_search_key varchar(255),
    --    resolution_uu uuid,
    --    chuboe_process_uu uuid
    --);
 
    --------------------------------
    -- create the process action transitions
    --------------------------------
    -- Define resolution records to be inserted
  	-- position 1: search key from resolution_type
        -- position 2: to_be name of the process resolution record
        -- position 3: to_be description of the process resolution record
    INSERT INTO chuboe_wf_template_temp_03_action_transition (temp_uu, action_search_key, chuboe_transition_uu, resolution_search_key) values
        ('e0d18935-c339-4b5e-baa4-07688c536300', 'submit', 'affda00d-e32a-4c67-82e0-236d08e426a7', 'pending'), --from:started  to:submitted state
        ('6dc21452-7a34-4bda-a615-dd380e663142', 'approve', 'f35840c2-dabf-4052-ae58-a534692ce9e7', 'approved'), --from:submitted to:replied state
        ('fca8ec65-1e1c-40ab-9526-67511588ab63', 'more-info', '192dcffc-7c06-484c-82cd-3587b0b0cbcf', 'pending'), --from:submitted to:started state 
        ('7bf71082-d24a-4760-83db-1a9e043f4a94', 'deny', 'f35840c2-dabf-4052-ae58-a534692ce9e7', 'denied'), --from:submitted  to:replied state
        ('4cc2c43f-33e8-4f15-af8a-eaf5379657de', 'close', '4603b103-0bbd-4a36-a62f-f306353db2f1', null) --from:replied to:finalized state
    ;
  
    UPDATE chuboe_wf_template_temp_03_action_transition t
    set action_uu = x.chuboe_action_uu
    from chuboe_action x
    where x.chuboe_process_uu = v_process_uu
      and x.search_key = t.action_search_key
    ;

    UPDATE chuboe_wf_template_temp_03_action_transition t
    set resolution_uu = x.chuboe_resolution_uu
    from chuboe_resolution x
    where x.chuboe_process_uu = v_process_uu
      and x.search_key = t.resolution_search_key
    ;

    INSERT INTO chuboe_action_transition_lnk (chuboe_transition_action_uu, chuboe_action_uu, chuboe_transition_uu, chuboe_resolution_uu)
        select t.temp_uu, t.action_uu, t.chuboe_transition_uu, t.resolution_uu
        from chuboe_wf_template_temp_03_action_transition t
    ;
  
    truncate chuboe_wf_template_temp_03_action_transition;

    
    -- Perform some operations on the temporary table
    --EXECUTE format('UPDATE %I SET age = age + 1 WHERE name LIKE $1', temp_table_name)
    --USING 'John%';
  
    -- Select data from the temporary table
    --EXECUTE format('SELECT * FROM %I', temp_table_name);
  
    RETURN v_process_uu;

    -- The temporary table will be automatically dropped when the function ends
END;
$$ LANGUAGE plpgsql;
