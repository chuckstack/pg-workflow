-- see function comments for formal description of what each function performs
-- the purpose of this file is to provide records that help kickstart process for the approval-traditional use case.


------------------------------------
-- approval process workflow seed --
------------------------------------

CREATE OR REPLACE FUNCTION stack_wf_template_process_create_approval_traditional(
    p_is_template boolean,
    p_topic text DEFAULT ''
) RETURNS uuid AS $$
DECLARE
    v_process_uu uuid;
    v_return_count numeric;
    v_topic text;
BEGIN
    
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
        search_key_type varchar(255), --optional - need if the actual search_key is different than the type search_key
        unique (table_name,search_key)
    );
    COMMENT ON TABLE pg_temp.kv IS '';

    -- Create a temporary convenience function to get the kv.uuid
    CREATE FUNCTION pg_temp.kvuu(search_key text, table_name text) RETURNS uuid AS $in$
        BEGIN
            RETURN (select s.uu from kv s where s.search_key = kvuu.search_key and s.table_name = kvuu.table_name);
        END;
        $in$ LANGUAGE plpgsql;

	-- create a temporary table to make it easy for users to specify what transitions should exist.
	CREATE TEMPORARY TABLE pg_temp.kv_transition(
        search_key varchar(255) not null,
        stack_wf_state_from_uu uuid not null,
        stack_wf_state_to_uu uuid not null,
        stack_wf_resolution_uu uuid,
		uu uuid not null default gen_random_uuid()
    );

	-- Create a temporary convenience function to get the kvt.uuid (transition)
    CREATE FUNCTION pg_temp.kvtuu(search_key text) RETURNS uuid AS $in$
        BEGIN
            RETURN (select s.uu from kv_transition s where s.search_key = kvtuu.search_key);
        END;
        $in$ LANGUAGE plpgsql;

    CREATE TEMPORARY TABLE pg_temp.kv_action_transition(
        stack_wf_action_uu uuid not null,
        stack_wf_transition_uu uuid not null,
        stack_wf_resolution_uu uuid,
		uu uuid not null default gen_random_uuid()
    );
    
    --------------------------------
    -- Insert the temp table data
    --------------------------------

    -- The kv table is where you (the user who might be modifying this function) define your custom states, actions, resolution and targets you want in your newly created process.
	-- insert entities into the temporary table - one value of this step is that it creates uuids for future use
    INSERT INTO kv (table_name,search_key,name,description,search_key_type) values
        ('stack_wf_process',    'xxxapproval_traditional', 'Traditional approval xxx', 'xxx traditional approval process','traditional'),
        ('stack_wf_state',      'started',              'New approval request', 'New xxx request',null),
        ('stack_wf_state',      'submitted',            'Approval request submitted', 'xxx request submitted to manager',null),
        ('stack_wf_state',      'replied',              'Approval request replied', 'Manager replied to xxx request',null),
        ('stack_wf_state',      'finalized',            'Approval request final closed', 'xxx request final closed',null),
        ('stack_wf_action',     'submit',               'Submit Request', 'Employee submits the xxx request',null),
        ('stack_wf_action',     'approve',              'Approve Request', 'Manager approves the xxx request',null),
        ('stack_wf_action',     'more-info',            'Request More Info', 'Manager needs more informationo to approve xxx request',null),
        ('stack_wf_action',     'deny',                 'Deny Request', 'Manager denies the xxx request',null),
        ('stack_wf_action',     'close',                'Close Request', 'Employee closes the xxx request as acknowledgement of the response',null),
        ('stack_wf_resolution', 'none', 		         null, null,null),
        ('stack_wf_resolution', 'approved', 	         null, null,null),
        ('stack_wf_resolution', 'pending', 		         null, null,null),
        ('stack_wf_resolution', 'denied', 		         null, null,null),
        ('stack_wf_group',      'managers',             'Managers', null,null),
        ('stack_wf_activity',   'send_email',           'Notify your peers that you will be out', null,null),
        ('stack_wf_target',     'requester',            'Requester', 'The user who initiated the request.',null),
        ('stack_wf_target',     'stakeholder',          'Stakeholders', 'The users who are stakeholders of the request.',null),
        ('stack_wf_target',     'group_member',         'Group Members', 'The users who are members of the group associated with the request.',null),
        ('stack_wf_target',     'process_admin',        'Process Admins', 'The users who are administrators of the process associated with the request.',null)
    ;

	-- insert transitions into the temporary table - one value of this step is that it creates uuids for future use
    INSERT INTO kv_transition (search_key, stack_wf_state_from_uu, stack_wf_state_to_uu, stack_wf_resolution_uu) values
        ('started-submitted', pg_temp.kvuu('started','stack_wf_state'),  pg_temp.kvuu('submitted','stack_wf_state'),null),
        ('submitted-replied', pg_temp.kvuu('submitted','stack_wf_state'),pg_temp.kvuu('replied','stack_wf_state'),  null),
        ('submitted-started', pg_temp.kvuu('submitted','stack_wf_state'),pg_temp.kvuu('started','stack_wf_state'),  null),
        ('replied-finalized', pg_temp.kvuu('replied','stack_wf_state'),  pg_temp.kvuu('finalized','stack_wf_state'),null)
	;
    
	-- insert action-transitions into the temporary table - one value of this step is that it creates uuids for future use
    INSERT INTO kv_action_transition (stack_wf_action_uu, stack_wf_transition_uu, stack_wf_resolution_uu) values
        (pg_temp.kvuu('submit','stack_wf_action'),  pg_temp.kvtuu('started-submitted'),pg_temp.kvuu('pending','stack_wf_resolution')),
        (pg_temp.kvuu('approve','stack_wf_action'),pg_temp.kvtuu('submitted-replied'),  pg_temp.kvuu('approved','stack_wf_resolution')),
        (pg_temp.kvuu('more-info','stack_wf_action'),pg_temp.kvtuu('submitted-started'),  pg_temp.kvuu('pending','stack_wf_resolution')),
        (pg_temp.kvuu('deny','stack_wf_action'),pg_temp.kvtuu('submitted-replied'),  pg_temp.kvuu('denied','stack_wf_resolution')),
        (pg_temp.kvuu('close','stack_wf_action'),  pg_temp.kvtuu('replied-finalized'),null)
	;
    
    --------------------------------
    -- Update variables and perform post processing if needed
    --------------------------------
    ----DEBUG
    --SELECT count(*) FROM kv INTO v_return_count;
    --RAISE NOTICE 'Inserted % records into kv', v_return_count;
    
    -- load process_uu into variable for convenience
    SELECT uu INTO v_process_uu
    FROM kv
    WHERE table_name = 'stack_wf_process'
    ;

    -- update kv table accordingly
    -- udpate proces name with template text if needed
    IF p_is_template THEN
        UPDATE kv
        set search_key = search_key || '_template',
        name = name || ' template',
        description = description || ' template'
        where table_name = 'stack_wf_process'
        ;
    END IF;

    -- string replace the 'xxx' above
    IF length(p_topic) > 0 THEN
        --prefix process
        select lower(replace(p_topic, ' ','_')) || '_'into v_topic;
        
        --update strings
        UPDATE kv
        set 
            search_key = replace(search_key, 'xxx', v_topic), 
            name = replace(name, 'xxx', p_topic), 
            description = replace(description, 'xxx', p_topic)
        ;
    END IF;


    --------------------------------
    -- create the process
    --------------------------------
	-- todo use kv table
    INSERT INTO stack_wf_process (stack_wf_process_uu, search_key, name, is_template, description, stack_wf_process_type_uu)
    SELECT tt.uu, tt.search_key, tt.name, p_is_template, tt.description, pt.stack_wf_process_type_uu
    FROM kv tt
    JOIN stack_wf_process_type pt on coalesce(tt.search_key_type,tt.search_key) = pt.search_key
    WHERE tt.table_name = 'stack_wf_process'
    ;
  
    --------------------------------
    -- create the process states
    --------------------------------
    -- note: the insert statement keeps search_key from the state_type. Stating this because below dependencies on the state search key.
    INSERT INTO stack_wf_state (stack_wf_state_uu, stack_wf_state_type_uu, stack_wf_process_uu, search_key, name, description)
    SELECT tt.uu, st.stack_wf_state_type_uu, v_process_uu, st.search_key, coalesce(tt.name,st.name), coalesce(tt.description,st.description)
    FROM kv tt
    JOIN stack_wf_state_type st on coalesce(tt.search_key_type, tt.search_key) = st.search_key 
    WHERE tt.table_name = 'stack_wf_state'
    ;
  
    --------------------------------
    -- create the process actions
    --------------------------------
    -- note: the insert statement keeps search_key from the action_type. Stating this because below dependencies on the action search key.
    INSERT INTO stack_wf_action (stack_wf_action_uu, stack_wf_action_type_uu, stack_wf_process_uu, search_key, name, description)
    SELECT tt.uu, st.stack_wf_action_type_uu, v_process_uu, st.search_key, coalesce(tt.name,st.name), coalesce(tt.description,st.description)
    FROM kv tt
    JOIN stack_wf_action_type st on coalesce(tt.search_key_type, tt.search_key) = st.search_key 
    WHERE tt.table_name = 'stack_wf_action'
    ;
  
    --------------------------------
    -- create the process resolutions
    --------------------------------
    -- note: the insert statement keeps search_key from the resolution_type. Stating this because below dependencies on the resolution search key.
    INSERT INTO stack_wf_resolution (stack_wf_resolution_uu, stack_wf_resolution_type_uu, stack_wf_process_uu, search_key, name, description)
    SELECT tt.uu, st.stack_wf_resolution_type_uu, v_process_uu, st.search_key, coalesce(tt.name,st.name), coalesce(tt.description,st.description)
    FROM kv tt
    JOIN stack_wf_resolution_type st on coalesce(tt.search_key_type, tt.search_key) = st.search_key 
    WHERE tt.table_name = 'stack_wf_resolution'
    ;
  
    --------------------------------
    -- create the process targets
    --------------------------------
    -- note: the insert statement keeps search_key from the target_type. Stating this because below dependencies on the target search key.
    INSERT INTO stack_wf_target (stack_wf_target_uu, stack_wf_target_type_uu, stack_wf_process_uu, search_key, name, description)
    SELECT tt.uu, st.stack_wf_target_type_uu, v_process_uu, st.search_key, coalesce(tt.name,st.name), coalesce(tt.description,st.description)
    FROM kv tt
    JOIN stack_wf_target_type st on coalesce(tt.search_key_type, tt.search_key) = st.search_key 
    WHERE tt.table_name = 'stack_wf_target'
    ;
  
    --------------------------------
    -- create the process groups
    --------------------------------
    -- note: the insert statement keeps search_key from the group_type. Stating this because below dependencies on the group search key.
    INSERT INTO stack_wf_group (stack_wf_group_uu, stack_wf_process_uu, search_key, name, description)
    SELECT tt.uu, v_process_uu, tt.search_key, tt.name, tt.description
    FROM kv tt
    WHERE tt.table_name = 'stack_wf_group'
    ;

    --------------------------------
    -- create the process activities
    --------------------------------
    -- note: the insert statement keeps search_key from the activity_type. Stating this because below dependencies on the activity search key.
    INSERT INTO stack_wf_activity (stack_wf_activity_uu, stack_wf_activity_type_uu, stack_wf_process_uu, search_key, name, description)
    SELECT tt.uu, st.stack_wf_activity_type_uu, v_process_uu, st.search_key, coalesce(tt.name,st.name), coalesce(tt.description,st.description)
    FROM kv tt
    JOIN stack_wf_activity_type st on coalesce(tt.search_key_type, tt.search_key) = st.search_key 
    WHERE tt.table_name = 'stack_wf_activity'
    ;
  
    --------------------------------
    -- create the process transitions
    --------------------------------
    INSERT INTO stack_wf_transition (search_key, stack_wf_transition_uu, stack_wf_state_current_uu, stack_wf_state_next_uu, stack_wf_resolution_uu)
    SELECT tt.search_key, tt.uu, tt.stack_wf_state_from_uu, tt.stack_wf_state_to_uu, tt.stack_wf_resolution_uu
    from kv_transition tt
    ;

    --------------------------------
    -- create the process action transitions
    --------------------------------
    INSERT INTO stack_wf_action_transition_lnk (stack_wf_action_transition_lnk_uu, stack_wf_action_uu, stack_wf_transition_uu, stack_wf_resolution_uu)
    SELECT tt.uu, tt.stack_wf_action_uu, tt.stack_wf_transition_uu, tt.stack_wf_resolution_uu
    FROM kv_action_transition tt
    ;
  
    RETURN v_process_uu;

    -- The temporary table will be automatically dropped when the session ends
END;
$$ LANGUAGE plpgsql;
COMMENT ON function stack_wf_template_process_create_approval_traditional(boolean,text) IS 'The purpose of this function is to automate the creation of a tradtional approval workflow. The p_is_template parameter determines if the process is flagged as a template. The p_topic topic looks for the xxx placeholder in the default text and replaces it accordingly so that users can better understand the purpose of the newly created process.';
