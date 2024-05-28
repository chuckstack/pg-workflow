-- the purpose of this file is to provide records that help kickstart process and request creation.

-- typical process
  -- state
  -- activity
  -- action
  -- target
  -- resolution
  -- transition

set search_path = private;

------------------------------------
-- approval process workflow seed --
------------------------------------

INSERT INTO chuboe_process (chuboe_process_uu, search_key, name, is_template, description)
VALUES ('414e5d60-4262-4998-b1b4-286840bfe397', 'sample_approval', 'Sample approval process', true, 'Template/example of an approval process.');

-- add states - note that each insert statment creates a unique state name and description to match the workflow use case
-- todo: create a better data structure to visualize the mapping between the state_type.search_key and the resulting state name and description.
INSERT INTO chuboe_state (chuboe_state_type_uu, chuboe_process_uu, search_key, name, description)
select chuboe_state_type_uu, '414e5d60-4262-4998-b1b4-286840bfe397', search_key, 'New approval request', 'New request for xxx' 
from chuboe_state_type
where search_key = 'started'
;
INSERT INTO chuboe_state (chuboe_state_type_uu, chuboe_process_uu, search_key, name, description)
select chuboe_state_type_uu, '414e5d60-4262-4998-b1b4-286840bfe397', search_key, 'Approval request submitted', 'Request submitted to manager for xxx' 
from chuboe_state_type
where search_key = 'submitted'
;
INSERT INTO chuboe_state (chuboe_state_type_uu, chuboe_process_uu, search_key, name, description)
select chuboe_state_type_uu, '414e5d60-4262-4998-b1b4-286840bfe397', search_key, 'Approval request replied', 'Manager replied to request for xxx - see resolution' 
from chuboe_state_type
where search_key = 'replied'
;
INSERT INTO chuboe_state (chuboe_state_type_uu, chuboe_process_uu, search_key, name, description)
select chuboe_state_type_uu, '414e5d60-4262-4998-b1b4-286840bfe397', search_key, 'Approval request final closed', 'Request for xxx final closed' 
from chuboe_state_type
where search_key = 'finalized'
;


--WITH my_state as (
--    select *
--    from chuboe_state_type
--) 
--INSERT INTO chuboe_state (chuboe_state_type_uu, chuboe_process_uu, search_key, name, description)
--select chuboe_state_type_uu, '414e5d60-4262-4998-b1b4-286840bfe397', search_key, name, name || ' - give me a better name and desc'
--from my_state
--;
