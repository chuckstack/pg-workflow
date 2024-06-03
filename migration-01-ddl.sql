-- The purpose of this file is to populate a newly created database is the table artifacts needed to create, maintain and execute workflows.
-- Great care has been given to create documentation in the form of table comments. If at any time the comments can be improved, please recommend improvements.
-- Great care has been given to order the tables exist in this file so that both 1. it works as a sql script and 2. the order aids users in understanding the natural order of how records are created and related.
-- When using this file to create examples, tools or interactions, ignore all todo statements.

--Table and column conventions:
  -- tables use uuid as primary keys. The purpose of this decision is to make creating very large (and often replicated) systems easier to manage. Doing so also allows for clients to define their own uuid values.
  -- all tables have a single primary key (even if it is a link table). The purpose of this decision is that it enables the concept of table_name + record_uu identification. Said another way, if you know the table_name and the record_uu of any given record, you can always find the details associated with that record. This convention also allows for maintaining centralized logs, attachments, and attributes.
  -- search_key is a user defined alphanumeric. The purpose of this column is to allow users to create keys that are more easily remembered by humans. It is up to the implementor to determine if the search_key should be unique. If it should be unique, the implementor determines the criteria for being unique. search_key columns are most appropriate for tables that maintain a primary concept but the record is not considered transactional. Examples of non-transactional records include users, business partners, and products.
  -- document_no is a user defined alphanumeric. The purpose of this column is to allow the system to auto-populate auto-incrementing document numbers. It is up to the implementor to determine if the document_no should be unique. If it should be unique, the implementor determines the criteria for being unique. document_no are most appropriate for tables that represent transactional data. Examples of a transaction records include invoices, orders, and payments.
  -- created is a timestamp indicating when the record was created.
  -- created_by is a uuid pointing to the database user/role that created the record.
  -- updated is a timestamp indicating when the record was last updated.
  -- updated_by is a uuid pointing to the database user/role that last updated the record.
  -- is_active is a boolean that indicates if a record can be modified. is_active also acts as a soft-delete. If a record has an is_active=false, the record should be be returned as an option for selection in future lists and drop down fields.
  -- is_default is a boolean that indicates if a record should represent a default option. Typically, only one records can have is_default=true; however, there are circumstances where multiple records in the same table can have is_default=true based on unique record attributes. Implementors chose the unique criteria for any given table with a is_default column.
  -- is_processed is a boolean that indicates of a record has reached its final state. Said another way, if a record's is_processed=true, then no part of the record should updated or deleted.
  -- is_template is a boolean that indicates if a record exists for the purpose of cloning.
  -- when naming columns the noun comes first and the adjective comes next. Example: stack_wf_state_next_uu where state is the noun and next is the adjective. The benefit of this approach is that like columns (and the resulting methods/calls) appear next to each other alphabetically.
  -- concept of function => create_from vs create_into -- attempt to support both when possible

create schema if not exists private;
set search_path = private;

CREATE TABLE stack_user (
  stack_user_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_key VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  first_name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  description TEXT
);
COMMENT ON TABLE stack_user IS 'Table that contains users. Users are a cross-process represenation of actors in a workflow. Any one user can participate in multiple processes. See also: stack_wf_group.';

-- create a default user
INSERT INTO stack_user (stack_user_uu, search_key, first_name, last_name, email, description)
VALUES
  ('984c9035-3be3-4998-b3e9-46620b091559', 'super_user', 'Super', 'User', 'superuser@system.com', 'First user created');

CREATE TABLE stack_wf_process_type (
  stack_wf_process_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  UNIQUE (search_key)
);
COMMENT ON TABLE stack_wf_process_type IS 'Table that represents the types of processes. A process type is a set of standardized, cross-process representations of the types of processes that exist. The purpose of this table is to provide reporting options for the resulting workflow processes and requests. The values in this table are near static, and they will not change often.';

-- Consider making this an enum since code will most likely be written against these values.
-- Here are reference values
INSERT INTO stack_wf_process_type (stack_wf_process_type_uu, search_key, name, description)
VALUES
  ('d4d85948-ee7e-4880-8269-e5cc85b3f2fe', 'traditional', 'Traditional', 'Workflow involving processes, actions, states, transitions, activities, requests and resolutions. This is the use case when you think of a business process management (BPM) diagram.'),
  ('366da8b2-6349-4b0a-a20b-febeede09c24', 'ad-hoc', 'Ad Hoc', 'Workflow offering the greatest freedom and flexibility in terms of the request life cycle. Ad hoc workflows are used when institutional knowledge of approval process are well understood. Said another way, users know what roles need to be consulted for what approvals. The system simply needs to make it easy to create and process the requests.'),
  ('1fb294eb-843f-44c4-9f0b-9a59bad37b43', 'queue-based', 'Queue-based', 'Activities that enable users or groups to see and navigate to records/documents that enter a specific state. If everyone in an organization were to know when they are needed, and if everyone acted accordingly in a timely manner, the world would be a better and more efficient place.'),
  ('b3f13a96-3f55-45cd-86ae-c530e97c4e2c', 'checklist', 'Checklist', 'Simple tracking what needs to happen and letting everyone know when stuff is done.');

CREATE TABLE stack_wf_target_type (
  stack_wf_target_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  UNIQUE (search_key)
);
COMMENT ON TABLE stack_wf_target_type IS 'Table that represents the types of targets or recipients of actions. A target type is a set of standardized, cross-process representations of groups that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often.';

-- Consider making this an enum since code will most likely be written against these values.
-- Here are reference values
INSERT INTO stack_wf_target_type (stack_wf_target_type_uu, search_key, name, description)
VALUES
  ('77c9aad9-5ff4-4fd0-a6fe-81295e419aea', 'requester', 'Requester', 'The user who initiated the request.'),
  ('7477f448-46c6-48a5-8f60-2c73aa124d28', 'stakeholder', 'Stakeholders', 'The users who are stakeholders of the request.'),
  ('517d9c38-85fd-4567-9ce4-d59e3d51d0af', 'group_member', 'Group Members', 'The users who are members of the group associated with the request.'),
  ('1b405fc3-90cf-41a5-9ed9-b60d35cfa44c', 'process_admin', 'Process Admins', 'The users who are administrators of the process associated with the request.');

CREATE TABLE stack_wf_state_type (
  stack_wf_state_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  is_default BOOLEAN DEFAULT FALSE,
  description TEXT,
  UNIQUE (search_key)
);
COMMENT ON TABLE stack_wf_state_type IS 'Table that defines the types of states of a request. It is important to note the difference between state and resolution. For example, a state might be "completed" but the resolution might be "Successful" or "failed". State type is a set of standardized, cross-process representations of states that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often. See also: stack_wf_state.';

-- Consider making this an enum since code will most likely be written against these values.
-- Here are reference values
INSERT INTO stack_wf_state_type (stack_wf_state_type_uu, search_key, name, description, is_default)
VALUES
  ('8cc3f867-8f75-4752-a91b-c92330979242', 'started', 'Started', 'Initial state for a newly created Request.', true),
  ('d5f2d251-4571-4638-823f-eecbf9fded5c', 'normal', 'Normal', 'A regular state with no special designation.', false),
  ('f5021a7f-8e2a-4da4-90e7-e80744a3f65d', 'submitted', 'Submitted', 'A state common to approvals indicating that someone has the next action.', false),
  ('9a2b6a08-e094-4c12-8df6-67f7218b1fd7', 'replied', 'Replied', 'A state indicating that a resolution has been assigned as has been sent back.', false),
  ('35e12c60-8a35-4855-b3d1-e9ebd0e09450', 'completed', 'Completed', 'A state signifying that any Request has reached a completed state.', false),
  ('c8046298-cdf0-4df2-be08-d8c5c5122bd7', 'finalized', 'Finalized', 'A state signifying that any Request has reached its final state and cannot be further changed.', false);

CREATE TABLE stack_wf_resolution_type (
  stack_wf_resolution_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  is_default BOOLEAN DEFAULT FALSE,
  description TEXT,
  UNIQUE (search_key)
);
COMMENT ON TABLE stack_wf_resolution_type IS 'Table that defines the types of resolutions of a request. It is important to note the difference between state and resolution. For example, a state might be "completed" but the resolution might be "Successful" or "failed". Resolution type is a set of standardized, cross-process representations of resolutions that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often. See also: stack_wf_resolution.';

-- Consider making this an enum since code will most likely be written against these values.
-- Here are reference values
INSERT INTO stack_wf_resolution_type (stack_wf_resolution_type_uu, search_key, name, description, is_default)
VALUES
  ('3dc67c8a-5649-4827-9ef6-4955a2edc39b', 'none', 'None', 'Initial resolution for a newly created request.', true),
  ('82cd3f23-34b9-4298-b418-2abbd69688e2', 'pending', 'Pending more information', 'A resolution indicating more information is needed before a decision is made.', false),
  ('03d9c94e-3fbc-4be5-9f2f-b3f99fd93f27', 'approved', 'Approved', 'A resolution indicating approval.', false),
  ('b27f21d3-0a16-4233-89b3-3f5cfc360729', 'success', 'Success', 'A resolution indicating success.', false),
  ('cb2c95c0-e73a-46df-b56a-ac5612b388b3', 'denied', 'Denied', 'A resolution indicating the request has been denied.', false),
  ('7b544603-3364-486d-8e38-fba4f18a065e', 'cancelled', 'Cancelled', 'A resolution indicating the request has been cancelled.', false);

CREATE TABLE stack_wf_activity_type (
  stack_wf_activity_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  UNIQUE (search_key)
);
COMMENT ON TABLE stack_wf_activity_type IS 'Table that defines the types of activities that can result from a request transitioning from one state to another. You might notice there is no concept of a task in this design. The activity is what should be done. The stack_wf_request_action_history table represent what pending task is to be done or what task was done. Activity type is a set of standardized, cross-process representations of the activities that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often. See also: stack_wf_activity.';

-- Consider making this an enum since code will most likely be written against these values.
-- Here are reference values
INSERT INTO stack_wf_activity_type (stack_wf_activity_type_uu, search_key, name, description)
VALUES
  ('ad958cf2-88e2-43f6-bbbe-b60a7301c0fa', 'add_note', 'Add Note', 'Specifies that we should automatically add a note to a Request.'),
  ('8e01c32b-b126-4cfd-9d55-a10ceb9cc3ed', 'send_email', 'Send Email', 'Specifies that we should send an email to one or more recipients.'),
  ('8c7ac90b-0c6a-4e4c-a9d4-e5d0ef7e24b6', 'add_stakeholder', 'Add Stakeholders', 'Specifies that we should add one or more persons as Stakeholders on this request.'),
  ('3b696f11-deba-4597-a5f4-cb02cf8a6d54', 'remove_stakeholder', 'Remove Stakeholders', 'Specifies that we should remove one or more stakeholders from this request.');


CREATE TABLE stack_wf_action_type (
  stack_wf_action_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  UNIQUE (search_key)
);
COMMENT ON TABLE stack_wf_action_type IS 'Table that defines the types of actions that can be performed to instigate a change in state. Action type is a set of standardized, cross-process representations of the actions that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often. See also: stack_wf_action.';

-- Consider making this an enum since code will most likely be written against these values.
-- Here are reference values
INSERT INTO stack_wf_action_type (stack_wf_action_type_uu, search_key, name, description)
VALUES
  ('afd4df79-6f85-423c-8d6d-31e320989320', 'prepare', 'Prepare', ''),
  ('827e84ab-1494-478d-bcff-cb1815ca8f28', 'complete', 'Complete', ''),
  ('b9e49598-7b41-4fd2-8ad1-274b6d24ecf8', 'close', 'Close', ''),
  --('69d32e62-f58b-4823-b704-930d75199da4', 'next', 'Go to next State', '') --need to think about this more...
  ('82d3b937-5e70-428a-b981-3262b6b09003', 'submit', 'Submit', ''),
  ('58494b59-a9aa-4cbc-a424-3f23ee660cf9', 'resubmit', 'Resubmit', ''),
  ('02117e4c-eb14-4771-b87f-034ad044c8c9', 'approve', 'Approve', ''),
  ('67ed3bb8-5878-4e05-9c15-f623f8d3bb32', 'deny', 'Deny', ''),
  ('beb23a0f-4379-480e-a05c-123cfdb96763', 'void', 'Void', ''),
  ('22b1a318-840d-4c44-bb0a-7ca49c01af9d', 'reverse', 'Reverse', ''),
  ('88a91b75-9e96-4371-a00d-fcbc59be9247', 'execute', 'Execute', ''),
  ('4b96b233-ab3a-48aa-a7d9-37ba2b7e763c', 'cancel', 'Cancel', ''),
  ('a412a325-999a-4f49-8333-906ffc36597a', 'restart', 'Restart', ''),
  ('813800e1-d194-4d56-92d9-49b44e33f497', 'resolve', 'Resolve', ''),
  ('d6789b41-9bb1-43f7-a05b-7076a508bb1a', 'more-info', 'Request more information', '')
;


CREATE TABLE stack_wf_process (
  stack_wf_process_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_process_type_uu UUID NOT NULL,
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  is_template BOOLEAN NOT NULL DEFAULT FALSE,
  is_processed BOOLEAN NOT NULL DEFAULT FALSE,
  description TEXT,
  FOREIGN KEY (stack_wf_process_type_uu) REFERENCES stack_wf_process_type(stack_wf_process_type_uu)
);
COMMENT ON TABLE stack_wf_process IS 'Table that represents the starting point of workflow design and execution. Processes describe how to get things done and my whom. A process describes what is possible in a workflow scenario. A process acts as a hub to collect workflow data about users, requests, states, actions, and transitions. Most of the remaining workflow tables reference a process directly or indirectly.';

CREATE TABLE stack_wf_group (
  stack_wf_group_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  stack_wf_process_uu UUID NOT NULL,
  FOREIGN KEY (stack_wf_process_uu) REFERENCES stack_wf_process(stack_wf_process_uu)
);
COMMENT ON TABLE stack_wf_group IS 'Table that represents a collection of people. Processes can be created that support both "any" an "all" scenarios. An "any" scenario is where any one member of the group can act to create succes. An "all" scenaio is where all members of the group must act to create successs. A group can also be thought of as a role where anyone in the group is assumed to be able to act in that role. There is a relationship between groups and targets. Targets are cross-process. Groups are specific to a process. Targets can be linked to process groups inside a process. This is a process attribute table.';

-- todo: note: the concept of a role is outside of the definition of a workflow. There are two types to people collections:
  -- group - specific to the workflow => process (local collection of users). Said another way, local to the worKflow application.
  -- role - global user collections
  -- The expectation is that you can populate a workflow process group from one or multiple roles

CREATE TABLE stack_wf_group_member_lnk (
  stack_wf_group_member_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_group_uu UUID NOT NULL,
  stack_user_uu UUID NOT NULL,
  FOREIGN KEY (stack_wf_group_uu) REFERENCES stack_wf_group(stack_wf_group_uu),
  FOREIGN KEY (stack_user_uu) REFERENCES stack_user(stack_user_uu),
  UNIQUE (stack_wf_group_uu, stack_user_uu)
);
COMMENT ON TABLE stack_wf_group_member_lnk IS 'Table that links users to a process group.';
-- todo: should members be added at the process level or the request level or both? Consider adding a stack_wf_request_uu column to identify if the link was established at the request level. If this change is made, move this table definition below the stack_wf_request table definition.

CREATE TABLE stack_wf_process_admin_lnk (
  stack_wf_process_admin_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_process_uu UUID NOT NULL,
  stack_user_uu UUID NOT NULL,
  FOREIGN KEY (stack_wf_process_uu) REFERENCES stack_wf_process(stack_wf_process_uu),
  FOREIGN KEY (stack_user_uu) REFERENCES stack_user(stack_user_uu),
  UNIQUE (stack_wf_process_uu, stack_user_uu)
);
COMMENT ON TABLE stack_wf_process_admin_lnk IS 'Table that links users to processes as someone who can administer a particular process. Admins can create, update and delete processes';

CREATE TABLE stack_wf_target (
  stack_wf_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_target_type_uu UUID NOT NULL,
  stack_wf_process_uu UUID NOT NULL,
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  FOREIGN KEY (stack_wf_target_type_uu) REFERENCES stack_wf_target_type(stack_wf_target_type_uu),
  FOREIGN KEY (stack_wf_process_uu) REFERENCES stack_wf_process(stack_wf_process_uu)
);
COMMENT ON TABLE stack_wf_target IS 'Table that represents the targets within a process. Note that we must first define the targets of a process before we can create a request. This is a process attribute table.';

CREATE TABLE stack_wf_state (
  stack_wf_state_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_state_type_uu UUID NOT NULL,
  stack_wf_process_uu UUID NOT NULL,
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  FOREIGN KEY (stack_wf_state_type_uu) REFERENCES stack_wf_state_type(stack_wf_state_type_uu),
  FOREIGN KEY (stack_wf_process_uu) REFERENCES stack_wf_process(stack_wf_process_uu)
);
COMMENT ON TABLE stack_wf_state IS 'Table that represents the states within a process. Note that we must first define the states of a process before we can create a request. This is a process attribute table.';

CREATE TABLE stack_wf_resolution (
  stack_wf_resolution_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_resolution_type_uu UUID NOT NULL,
  stack_wf_process_uu UUID NOT NULL,
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  FOREIGN KEY (stack_wf_resolution_type_uu) REFERENCES stack_wf_resolution_type(stack_wf_resolution_type_uu),
  FOREIGN KEY (stack_wf_process_uu) REFERENCES stack_wf_process(stack_wf_process_uu)
);
COMMENT ON TABLE stack_wf_resolution IS 'Table that represents the resolutions within a process. Note that we must first define the resolutions of a process before we can create a request. This is a process attribute table.';

CREATE TABLE stack_wf_action (
  stack_wf_action_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_action_type_uu UUID NOT NULL,
  stack_wf_process_uu UUID NOT NULL,
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  FOREIGN KEY (stack_wf_action_type_uu) REFERENCES stack_wf_action_type(stack_wf_action_type_uu),
  FOREIGN KEY (stack_wf_process_uu) REFERENCES stack_wf_process(stack_wf_process_uu)
);
COMMENT ON TABLE stack_wf_action IS 'Table that represents the actions that can or should be performed to change the state in a specific request. This is a request attribute table. This is a process attribute table.';

CREATE TABLE stack_wf_request (
  stack_wf_request_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_process_uu UUID NOT NULL,
  search_key VARCHAR(255) NOT NULL,
  date_requested TIMESTAMP NOT NULL,
  stack_user_uu UUID NOT NULL,
  stack_wf_state_uu UUID NOT NULL,
  stack_wf_resolution_uu UUID NOT NULL,
  FOREIGN KEY (stack_wf_process_uu) REFERENCES stack_wf_process(stack_wf_process_uu),
  FOREIGN KEY (stack_user_uu) REFERENCES stack_user(stack_user_uu),
  FOREIGN KEY (stack_wf_state_uu) REFERENCES stack_wf_state(stack_wf_state_uu),
  FOREIGN KEY (stack_wf_resolution_uu) REFERENCES stack_wf_resolution(stack_wf_resolution_uu)
);
COMMENT ON TABLE stack_wf_request IS 'Table that represents an instance of a process. A request is defined by its process. A request (and its "request attribute tables") describe all that occured to achieve the current state of an active request and that occured in a completed request. Note that the request maintains its current state as a column in the stack_wf_request table. All other request attributes are maintains in "request attribute tables".';
-- todo: the user_name column does not make any sense - or is not that useful

CREATE TABLE stack_wf_request_note (
  stack_wf_request_note_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_request_uu UUID NOT NULL,
  stack_user_uu UUID NOT NULL,
  note TEXT NOT NULL,
  FOREIGN KEY (stack_wf_request_uu) REFERENCES stack_wf_request(stack_wf_request_uu),
  FOREIGN KEY (stack_user_uu) REFERENCES stack_user(stack_user_uu)
);
COMMENT ON TABLE stack_wf_request_note IS 'Table that stores notes associated with a specific request and user. This is a request attribute table.';

CREATE TABLE stack_wf_request_data (
  stack_wf_request_data_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_request_uu UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  value VARCHAR(255) NOT NULL,
  FOREIGN KEY (stack_wf_request_uu) REFERENCES stack_wf_request(stack_wf_request_uu)
);
COMMENT ON TABLE stack_wf_request_data IS 'Table that stores highly-variable data associated with a specific request. This is a request attribute table.';

CREATE TABLE stack_wf_request_file (
  stack_wf_request_file_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_request_uu UUID NOT NULL,
  stack_user_uu UUID NOT NULL,
  date_uploaded TIMESTAMP NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_content BYTEA NOT NULL,
  mime_type VARCHAR(255) NOT NULL,
  FOREIGN KEY (stack_wf_request_uu) REFERENCES stack_wf_request(stack_wf_request_uu),
  FOREIGN KEY (stack_user_uu) REFERENCES stack_user(stack_user_uu)
);
COMMENT ON TABLE stack_wf_request_file IS 'Table that stores files associated with a specific request and user. This is a request attribute table.';

CREATE TABLE stack_wf_request_stakeholder_lnk (
  stack_wf_request_stakeholder_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_request_uu UUID NOT NULL,
  stack_user_uu UUID NOT NULL,
  FOREIGN KEY (stack_wf_request_uu) REFERENCES stack_wf_request(stack_wf_request_uu),
  FOREIGN KEY (stack_user_uu) REFERENCES stack_user(stack_user_uu),
  UNIQUE (stack_wf_request_uu, stack_user_uu)
);
COMMENT ON TABLE stack_wf_request_stakeholder_lnk IS 'Table that links a user to a request thereby promoting the user to the role of stakeholder. A stakeholder is someone with a shared interest in a request life-cycle or resolution.  It is common for a stakeholder to request notifications when something about a request changes. This is a request attribute table.';
-- todo: developer note: determine if this table is really needed. There is already a stack_wf_group (role) table that can be used to create a stakeholder group.

CREATE TABLE stack_wf_transition (
  stack_wf_transition_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_state_current_uu UUID NOT NULL,
  stack_wf_state_next_uu UUID NOT NULL,
  stack_wf_resolution_uu UUID,
  FOREIGN KEY (stack_wf_state_current_uu) REFERENCES stack_wf_state(stack_wf_state_uu),
  FOREIGN KEY (stack_wf_state_next_uu) REFERENCES stack_wf_state(stack_wf_state_uu),
  FOREIGN KEY (stack_wf_resolution_uu) REFERENCES stack_wf_resolution(stack_wf_resolution_uu),
  UNIQUE (stack_wf_state_current_uu, stack_wf_state_next_uu, stack_wf_resolution_uu)
);
COMMENT ON TABLE stack_wf_transition IS 'Table that defines the transitions between states in a process. Processes represent a flow chart, and to do that we need to be able to move requests between states. A transition is a path between two states that shows how a request can travel between them. Note that setting a resolution is optional. If you include resolutions, you might need to specify the same transition multiple times (once per resolution). These records will act as options for the user and help them automatically set the resolution based on their choice. Transitions are initiated as a result of one or more actions. Transitions are unique to a process.';

CREATE TABLE stack_wf_activity (
  stack_wf_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_activity_type_uu UUID NOT NULL,
  stack_wf_process_uu UUID NOT NULL,
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  FOREIGN KEY (stack_wf_activity_type_uu) REFERENCES stack_wf_activity_type(stack_wf_activity_type_uu),
  FOREIGN KEY (stack_wf_process_uu) REFERENCES stack_wf_process(stack_wf_process_uu)
);
COMMENT ON TABLE stack_wf_activity IS 'Table that represents the activities that can be performed in a specific process. Activities are things that can happen as a result of a Request entering a state or following a transition. You might notice there is no concept of a task in this design. The activity is what should be done. The stack_wf_request_action_history table represents what pending task is to be done or what task was done. This is a request attribute table.';

CREATE TABLE stack_wf_state_activity_lnk (
  stack_wf_state_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_state_uu UUID NOT NULL,
  stack_wf_activity_uu UUID NOT NULL,
  FOREIGN KEY (stack_wf_state_uu) REFERENCES stack_wf_state(stack_wf_state_uu),
  FOREIGN KEY (stack_wf_activity_uu) REFERENCES stack_wf_activity(stack_wf_activity_uu),
  UNIQUE (stack_wf_state_uu, stack_wf_activity_uu)
);
COMMENT ON TABLE stack_wf_state_activity_lnk IS 'Table that links activities to their respective states in a specific process. This table allows you to specify that the system should execute a specific activity as a result of entering a specific state.';
-- todo: consider adding an attribute to this table dictating if the state is the to_be_state (entering) or the from_state (exiting). Currently exiting a state is silent.

CREATE TABLE stack_wf_transition_activity_lnk (
  stack_wf_transition_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_activity_uu UUID NOT NULL,
  stack_wf_transition_uu UUID NOT NULL,
  FOREIGN KEY (stack_wf_activity_uu) REFERENCES stack_wf_activity(stack_wf_activity_uu),
  FOREIGN KEY (stack_wf_transition_uu) REFERENCES stack_wf_transition(stack_wf_transition_uu),
  UNIQUE (stack_wf_activity_uu, stack_wf_transition_uu)
);
COMMENT ON TABLE stack_wf_transition_activity_lnk IS 'Table that links activities to their respective transitions in a specific process. This table allows you to specify that the system should execute a specific activity as a result of performing a specific transition.';

CREATE TABLE stack_wf_action_transition_lnk (
  stack_wf_transition_action_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_action_uu UUID NOT NULL,
  stack_wf_transition_uu UUID NOT NULL,
  stack_wf_resolution_uu UUID,
  FOREIGN KEY (stack_wf_transition_uu) REFERENCES stack_wf_transition(stack_wf_transition_uu),
  FOREIGN KEY (stack_wf_action_uu) REFERENCES stack_wf_action(stack_wf_action_uu),
  FOREIGN KEY (stack_wf_resolution_uu) REFERENCES stack_wf_resolution(stack_wf_resolution_uu),
  UNIQUE (stack_wf_transition_uu, stack_wf_action_uu, stack_wf_resolution_uu)
);
COMMENT ON TABLE stack_wf_action_transition_lnk IS 'Table that links actions to transitions in the workflow process. This table defines what actions can be performed to initiate a particular transition. Note that setting a resolution is optional. If you include resolutions, you might need to specify the same action multiple times (once per resolution). These records will act as options for the user and help them automatically set the resolution based on their choice. If you link an action to a transition with conflicting resolutions, the actions resolution will win since this is the users choice.';
-- todo: need a test/validator to identify conflicting resolutions

CREATE TABLE stack_wf_action_target_lnk (
  stack_wf_action_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_action_uu UUID NOT NULL,
  stack_wf_target_uu UUID NOT NULL,
  stack_wf_group_uu UUID, -- can be null - only accept when target => is_show_group=Y
  FOREIGN KEY (stack_wf_action_uu) REFERENCES stack_wf_action(stack_wf_action_uu),
  FOREIGN KEY (stack_wf_target_uu) REFERENCES stack_wf_target(stack_wf_target_uu),
  FOREIGN KEY (stack_wf_group_uu) REFERENCES stack_wf_group(stack_wf_group_uu),
  UNIQUE (stack_wf_action_uu, stack_wf_target_uu)
);
COMMENT ON TABLE stack_wf_action_target_lnk IS 'Table that links actions to their respective targets and associated groups. This tables acts as an access list to dictate who can perform what actions. If a group is the action target, then any member of the group can perform the action for it to be valid.';

CREATE TABLE stack_wf_activity_target_lnk (
  stack_wf_activity_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_activity_uu UUID NOT NULL,
  stack_wf_target_uu UUID NOT NULL,
  stack_wf_group_uu UUID, -- can be null - only accept when target => is_show_group=Y
  FOREIGN KEY (stack_wf_activity_uu) REFERENCES stack_wf_activity(stack_wf_activity_uu),
  FOREIGN KEY (stack_wf_target_uu) REFERENCES stack_wf_target(stack_wf_target_uu),
  FOREIGN KEY (stack_wf_group_uu) REFERENCES stack_wf_group(stack_wf_group_uu),
  UNIQUE (stack_wf_activity_uu, stack_wf_target_uu)
);
COMMENT ON TABLE stack_wf_activity_target_lnk IS 'Table that links activities to their respective targets in the workflow process. This tables dictates who receives what activities. If a group is an activity target, then all members of the group receive the activity (e.g. everyone in the group gets an email).';

CREATE TABLE stack_wf_request_activity_history (
  stack_wf_request_activity_history_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stack_wf_request_uu UUID NOT NULL,
  stack_wf_activity_uu UUID NOT NULL,
  stack_wf_transition_uu UUID NOT NULL,
  stack_wf_group_uu UUID, 
  stack_user_uu UUID, 
  stack_wf_target_uu UUID,
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  is_processed BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (stack_wf_request_uu) REFERENCES stack_wf_request(stack_wf_request_uu),
  FOREIGN KEY (stack_wf_activity_uu) REFERENCES stack_wf_activity(stack_wf_activity_uu),
  FOREIGN KEY (stack_wf_target_uu) REFERENCES stack_wf_target(stack_wf_target_uu),
  FOREIGN KEY (stack_wf_group_uu) REFERENCES stack_wf_group(stack_wf_group_uu),
  FOREIGN KEY (stack_user_uu) REFERENCES stack_user(stack_user_uu),
  FOREIGN KEY (stack_wf_transition_uu) REFERENCES stack_wf_transition(stack_wf_transition_uu)
);
COMMENT ON TABLE stack_wf_request_activity_history IS 'Table that records every activity that resulted from a transition along with the target, the user/group that resulted from the target and the records is_processed status. One can query this table to see all pending activities (is_processed = false) per request';
