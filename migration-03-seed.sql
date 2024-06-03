-- the purpose of this file is to provide records that help kickstart process for the approval-traditional use case.

-- todo:
   -- replace v_process_uu - now in kv table

set search_path = private;

------------------------------------
-- approval process workflow seed --
------------------------------------

CREATE OR REPLACE FUNCTION chuboe_wf_template_create_approval(p_is_template boolean) RETURNS uuid AS $$
DECLARE
    v_process_uu uuid;
    v_return_count numeric;
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

    -- The kv table is where you (the user who might be modifying this function) define your custom states, actions, resolution and targets you want in your newly created process.
	-- insert entities into the temporary table - one value of this step is that it creates uuids for future use
    INSERT INTO kv (table_name,search_key,name,description,search_key_type) values
        ('chuboe_process',    'sample_approval', 'Sample approval process', 'Template/example of an approval process.','traditional'),
        ('chuboe_state',      'started',         'New approval request', 'New xxx request',null),
        ('chuboe_state',      'submitted',       'Approval request submitted', 'xxx request submitted to manager',null),
        ('chuboe_state',      'replied',         'Approval request replied', 'Manager replied to xxx request',null),
        ('chuboe_state',      'finalized',       'Approval request final closed', 'xxx request final closed',null),
        ('chuboe_action',     'submit',          'Submit Request', 'Employee submits the xxx request',null),
        ('chuboe_action',     'approve',         'Approve Request', 'Manager approves the xxx request',null),
        ('chuboe_action',     'more-info',       'Request More Info', 'Manager needs more informationo to approve  xxx request',null),
        ('chuboe_action',     'deny',            'Deny Request', 'Manager denies the xxx request',null),
        ('chuboe_action',     'close',           'Close Request', 'Employee closes the xxx request as acknowledgement of the response',null),
        ('chuboe_resolution', 'none', 			  null, null,null),
        ('chuboe_resolution', 'approved', 		  null, null,null),
        ('chuboe_resolution', 'pending', 		  null, null,null),
        ('chuboe_resolution', 'denied', 		  null, null,null),
        ('chuboe_group',      'managers', 		  'Managers', null,null),
        ('chuboe_target',     'requester', 	     'Requester', 'The user who initiated the request.',null),
        ('chuboe_target',     'stakeholder',  	 'Stakeholders', 'The users who are stakeholders of the request.',null),
        ('chuboe_target',     'group_member',    'Group Members', 'The users who are members of the group associated with the request.',null),
        ('chuboe_target',     'process_admin',   'Process Admins', 'The users who are administrators of the process associated with the request.',null)
    ;
    ----DEBUG
    --SELECT count(*) FROM kv INTO v_return_count;
    --RAISE NOTICE 'Inserted % records into kv', v_return_count;
    
    -- load process_uu into variable for convenience
    SELECT uu INTO v_process_uu
    FROM kv
    WHERE table_name = 'chuboe_process'
    ;

	-- insert transitions into the temporary table - one value of this step is that it creates uuids for future use
    INSERT INTO kv_transition (search_key, chuboe_state_from_uu, chuboe_state_to_uu, chuboe_resolution_uu) values
        ('started-submitted', pg_temp.kvuu('started','chuboe_state'),  pg_temp.kvuu('submitted','chuboe_state'),null),
        ('submitted-replied', pg_temp.kvuu('submitted','chuboe_state'),pg_temp.kvuu('replied','chuboe_state'),  null),
        ('submitted-started', pg_temp.kvuu('submitted','chuboe_state'),pg_temp.kvuu('started','chuboe_state'),  null),
        ('replied-finalized', pg_temp.kvuu('replied','chuboe_state'),  pg_temp.kvuu('finalized','chuboe_state'),null)
	;
    
	-- insert action-transitions into the temporary table - one value of this step is that it creates uuids for future use
    INSERT INTO kv_action_transition (chuboe_action_uu, chuboe_transition_uu, chuboe_resolution_uu) values
        (pg_temp.kvuu('submit','chuboe_action'),  pg_temp.kvtuu('started-submitted'),pg_temp.kvuu('pending','chuboe_resolution')),
        (pg_temp.kvuu('approve','chuboe_action'),pg_temp.kvtuu('submitted-replied'),  pg_temp.kvuu('approved','chuboe_resolution')),
        (pg_temp.kvuu('more-info','chuboe_action'),pg_temp.kvtuu('submitted-started'),  pg_temp.kvuu('pending','chuboe_resolution')),
        (pg_temp.kvuu('deny','chuboe_action'),pg_temp.kvtuu('submitted-replied'),  pg_temp.kvuu('denied','chuboe_resolution')),
        (pg_temp.kvuu('close','chuboe_action'),  pg_temp.kvtuu('replied-finalized'),null)
	;

    --------------------------------
    -- create the process
    --------------------------------
	-- todo use kv table
    INSERT INTO chuboe_process (chuboe_process_uu, search_key, name, is_template, description, chuboe_process_type_uu)
    SELECT tt.uu, tt.search_key, tt.name, p_is_template, tt.description, pt.chuboe_process_type_uu
    FROM kv tt
    JOIN chuboe_process_type pt on coalesce(tt.search_key_type,tt.search_key) = pt.search_key
    WHERE tt.table_name = 'chuboe_process'
    ;
  
    --------------------------------
    -- create the process states
    --------------------------------
    -- note: the insert statement keeps search_key from the state_type. Stating this because below dependencies on the state search key.
    INSERT INTO chuboe_state (chuboe_state_uu, chuboe_state_type_uu, chuboe_process_uu, search_key, name, description)
    SELECT tt.uu, st.chuboe_state_type_uu, v_process_uu, st.search_key, coalesce(tt.name,st.name), coalesce(tt.description,st.description)
    FROM kv tt
    JOIN chuboe_state_type st on coalesce(tt.search_key_type, tt.search_key) = st.search_key 
    WHERE tt.table_name = 'chuboe_state'
    ;
  
    --------------------------------
    -- create the process actions
    --------------------------------
    -- note: the insert statement keeps search_key from the action_type. Stating this because below dependencies on the action search key.
    INSERT INTO chuboe_action (chuboe_action_uu, chuboe_action_type_uu, chuboe_process_uu, search_key, name, description)
    SELECT tt.uu, st.chuboe_action_type_uu, v_process_uu, st.search_key, coalesce(tt.name,st.name), coalesce(tt.description,st.description)
    FROM kv tt
    JOIN chuboe_action_type st on coalesce(tt.search_key_type, tt.search_key) = st.search_key 
    WHERE tt.table_name = 'chuboe_action'
    ;
  
    --------------------------------
    -- create the process resolutions
    --------------------------------
    -- note: the insert statement keeps search_key from the resolution_type. Stating this because below dependencies on the resolution search key.
    INSERT INTO chuboe_resolution (chuboe_resolution_uu, chuboe_resolution_type_uu, chuboe_process_uu, search_key, name, description)
    SELECT tt.uu, st.chuboe_resolution_type_uu, v_process_uu, st.search_key, coalesce(tt.name,st.name), coalesce(tt.description,st.description)
    FROM kv tt
    JOIN chuboe_resolution_type st on coalesce(tt.search_key_type, tt.search_key) = st.search_key 
    WHERE tt.table_name = 'chuboe_resolution'
    ;
  
    --------------------------------
    -- create the process targets
    --------------------------------
    -- note: the insert statement keeps search_key from the target_type. Stating this because below dependencies on the target search key.
    INSERT INTO chuboe_target (chuboe_target_uu, chuboe_target_type_uu, chuboe_process_uu, search_key, name, description)
    SELECT tt.uu, st.chuboe_target_type_uu, v_process_uu, st.search_key, coalesce(tt.name,st.name), coalesce(tt.description,st.description)
    FROM kv tt
    JOIN chuboe_target_type st on coalesce(tt.search_key_type, tt.search_key) = st.search_key 
    WHERE tt.table_name = 'chuboe_target'
    ;
  
    --------------------------------
    -- create the process groups
    --------------------------------
    -- note: the insert statement keeps search_key from the group_type. Stating this because below dependencies on the group search key.
    INSERT INTO chuboe_group (chuboe_group_uu, chuboe_process_uu, search_key, name, description)
    SELECT tt.uu, v_process_uu, tt.search_key, tt.name, tt.description
    FROM kv tt
    WHERE tt.table_name = 'chuboe_group'
    ;

    --------------------------------
    -- create the process transitions
    --------------------------------
    INSERT INTO chuboe_transition (chuboe_transition_uu, chuboe_state_current_uu, chuboe_state_next_uu, chuboe_resolution_uu)
    SELECT tt.uu, tt.chuboe_state_from_uu, tt.chuboe_state_to_uu, tt.chuboe_resolution_uu
    from kv_transition tt
    ;

    --------------------------------
    -- create the process action transitions
    --------------------------------
    INSERT INTO chuboe_action_transition_lnk (chuboe_transition_action_uu, chuboe_action_uu, chuboe_transition_uu, chuboe_resolution_uu)
    SELECT tt.uu, tt.chuboe_action_uu, tt.chuboe_transition_uu, tt.chuboe_resolution_uu
    FROM kv_action_transition tt
    ;
  
    RETURN v_process_uu;

    -- The temporary table will be automatically dropped when the session ends
END;
$$ LANGUAGE plpgsql;

--select 'here here here';
--
--select * from pg_temp.kv;
--select * from pg_temp.kv_transition;
--select * from pg_temp.kv_action_transition;
