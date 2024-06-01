-- the purpose of this file is to provide records that help kickstart process and request creation.

set search_path = private;

------------------------------------
-- approval process workflow seed --
------------------------------------

CREATE OR REPLACE FUNCTION chuboe_wf_template_create_approval() RETURNS uuid AS $$
DECLARE
    v_process_uu uuid;
BEGIN
    set search_path = private,pg_temp;
    
    --------------------------------
    -- create the temporary tables and functions
    --------------------------------
    -- note: The temp tables and functions are created in the pg_temp space; therefore they are local to the session.
    -- reference: https://stackoverflow.com/questions/39983154/how-do-i-create-a-nested-function-in-pl-pgsql
    
    -- create a temporary table to hold search_key, name, description and uuid for to be created values
    -- the purpose of this table is to make it easy for users to specify what entities get pulled from their respective types.
    CREATE TEMPORARY TABLE pg_temp.kv(
        table_name varchar(255) not null,
        search_key varchar(255) not null,
        name varchar(255),
        description text,
        uu uuid not null default gen_random_uuid(),
        unique (table_name,search_key)
    );

    -- Create a temporary convenience function to get the kv.uuid
    CREATE FUNCTION pg_temp.kvuu(search_key text, table_name text) RETURNS uuid AS $in$
        BEGIN
            RETURN (select s.uu from kv s where s.search_key = kvuu.search_key and s.table_name = kvuu.table_name);
        END;
        $in$ LANGUAGE plpgsql;

    -- Create a temporary convenience function to get the kv.name
    CREATE FUNCTION pg_temp.kvname(search_key text, table_name text) RETURNS varchar(255) AS $in$
        BEGIN
            RETURN (select s.name from kv s where s.search_key = kvname.search_key and s.table_name = kvname.table_name);
        END;
        $in$ LANGUAGE plpgsql;

    -- Create a temporary convenience function to get the kv.description
    CREATE FUNCTION pg_temp.kvdesc(search_key text, table_name text) RETURNS text AS $in$
        BEGIN
            RETURN (select s.description from kv s where s.search_key = kvdesc.search_key and s.table_name = kvdesc.table_name);
        END;
        $in$ LANGUAGE plpgsql;

	-- create a temporary table to make it easy for users to specify what transitions should exist.
	CREATE TEMPORARY TABLE pg_temp.kv_transition(
        search_key varchar(255) not null,
        chuboe_state_from_uu uuid not null,
        chuboe_state_to_uu uuid not null,
        chuboe_resolution_uu uuid,
		uu uuid not null default gen_random_uuid()
    );

	-- Create a temporary convenience function to get the kvt.uuid (transition)
    CREATE FUNCTION pg_temp.kvtuu(search_key text) RETURNS uuid AS $in$
        BEGIN
            RETURN (select s.uu from kv_transition s where s.search_key = kvtuu.search_key);
        END;
        $in$ LANGUAGE plpgsql;

    CREATE TEMPORARY TABLE pg_temp.kv_action_transition(
        chuboe_action_uu uuid not null,
        chuboe_transition_uu uuid not null,
        chuboe_resolution_uu uuid,
		uu uuid not null default gen_random_uuid()
    );

    -- note: by convention, I am giving each entity the same search_key as its respective type to make type uuid lookups easy.
    -- example: the chuboe_state search key "started" is the same as the chuboe_state_type.
    -- The kv table is where you (the user who might be modifying this function) define your custom states, actions, resolution and targets you want in your newly created process.
	-- insert entities into the temporary table - one value of this step is that it creates uuids for future use
    INSERT INTO kv (table_name,search_key,name,description) values
        ('chuboe_process',    'sample_approval', 'Sample approval process', 'Template/example of an approval process.'),
        ('chuboe_state',      'started',         'New approval request', 'New xxx request'),
        ('chuboe_state',      'submitted',       'Approval request submitted', 'xxx request submitted to manager'),
        ('chuboe_state',      'replied',         'Approval request replied', 'Manager replied to xxx request'),
        ('chuboe_state',      'finalized',       'Approval request final closed', 'xxx request final closed'),
        ('chuboe_action',     'submit',          'Submit Request', 'Employee submits the xxx request'),
        ('chuboe_action',     'approve',         'Approve Request', 'Manager approves the xxx request'),
        ('chuboe_action',     'more-info',       'Request More Info', 'Manager needs more informationo to approve  xxx request'),
        ('chuboe_action',     'deny',            'Deny Request', 'Manager denies the xxx request'),
        ('chuboe_action',     'close',           'Close Request', 'Employee closes the xxx request as acknowledgement of the response'),
        ('chuboe_resolution', 'none', 			  null, null),
        ('chuboe_resolution', 'approved', 		  null, null),
        ('chuboe_resolution', 'pending', 		  null, null),
        ('chuboe_resolution', 'denied', 		  null, null),
        ('chuboe_group',      'managers', 		  null, null),
        ('chuboe_target',     'requester', 	     'Requester', 'The user who initiated the request.'),
        ('chuboe_target',     'stakeholder',  	 'Stakeholders', 'The users who are stakeholders of the request.'),
        ('chuboe_target',     'group_member',    'Group Members', 'The users who are members of the group associated with the request.'),
        ('chuboe_target',     'process_admin',   'Process Admins', 'The users who are administrators of the process associated with the request.')
    ;
    
	-- insert transitions into the temporary table - one value of this step is that it creates uuids for future use
    INSERT INTO kv_transition (search_key, chuboe_state_from_uu, chuboe_state_to_uu, chuboe_resolution_uu) values
        ('started-submitted', pg_temp.kvuu('started','chuboe_state'),  pg_temp.kvuu('submitted','chuboe_state'),null),
        ('submitted-replied', pg_temp.kvuu('submitted','chuboe_state'),pg_temp.kvuu('replied','chuboe_state'),  null),
        ('submitted-started', pg_temp.kvuu('submitted','chuboe_state'),pg_temp.kvuu('started','chuboe_state'),  null),
        ('replied-finalized', pg_temp.kvuu('replied','chuboe_state'),  pg_temp.kvuu('finalized','chuboe_state'),null)
	;
    
	-- insert transitions into the temporary table - one value of this step is that it creates uuids for future use
    INSERT INTO kv_action_transition (chuboe_action_uu, chuboe_transition_uu, chuboe_resolution_uu) values
        (pg_temp.kvuu('submit','chuboe_action'),  pg_temp.kvtuu('started-submitted'),pg_temp.kvuu('pending','chuboe_resolution')),
        (pg_temp.kvuu('approve','chuboe_action'),pg_temp.kvtuu('submitted-replied'),  pg_temp.kvuu('approved','chuboe_resolution')),
        (pg_temp.kvuu('more-info','chuboe_action'),pg_temp.kvtuu('submitted-started'),  pg_temp.kvuu('pending','chuboe_resolution')),
        (pg_temp.kvuu('deny','chuboe_action'),pg_temp.kvtuu('submitted-replied'),  pg_temp.kvuu('denied','chuboe_resolution')),
        (pg_temp.kvuu('close','chuboe_action'),  pg_temp.kvtuu('replied-finalized'),null)
	;
    


	-- todo delete me and refactor
    -- state, action and resolution
    CREATE TEMPORARY TABLE chuboe_wf_template_temp_01(
        search_key varchar(255),
        name varchar(255),
        description varchar(255) 
    );
    
	-- todo rename me and refactor - add to pg_temp schema
	-- todo remove many of the uuid or key columns since should not be needed
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
 
	-- todo rename me and refactor - add to pg_temp schema
	-- todo remove many of the uuid or key columns since should not be needed
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
	-- todo use kv table
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
