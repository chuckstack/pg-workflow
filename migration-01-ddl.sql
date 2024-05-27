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

create schema if not exists private;
set search_path = private;

CREATE TABLE chuboe_user (
  chuboe_user_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_key VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  first_name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  description TEXT
);
COMMENT ON TABLE chuboe_user IS 'Table that contains users. Users are a cross-process represenation of actors in a workflow. Any one user can participate in multiple processes. See also: chuboe_group.';

-- create a default user
INSERT INTO chuboe_user (chuboe_user_uu, search_key, first_name, last_name, email, description)
VALUES
  ('984c9035-3be3-4998-b3e9-46620b091559', 'super_user', 'Super', 'User', 'superuser@system.com', 'First user created');

CREATE TABLE chuboe_target (
  chuboe_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  is_show_group BOOLEAN DEFAULT FALSE
);
COMMENT ON TABLE chuboe_target IS 'Table that represents the targets or recipients of actions. A target is a set of standardized, cross-process representations of groups that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often.';

-- Consider making this an enum since code will most likely be written against these values.
-- Here are reference values
INSERT INTO chuboe_target (chuboe_target_uu, name, description)
VALUES
  ('77c9aad9-5ff4-4fd0-a6fe-81295e419aea', 'Requester', 'The user who initiated the request.'),
  ('7477f448-46c6-48a5-8f60-2c73aa124d28', 'Stakeholders', 'The users who are stakeholders of the request.'),
  ('517d9c38-85fd-4567-9ce4-d59e3d51d0af', 'Group Members', 'The users who are members of the group associated with the request.'),
  ('1b405fc3-90cf-41a5-9ed9-b60d35cfa44c', 'Process Admins', 'The users who are administrators of the process associated with the request.');

CREATE TABLE chuboe_state_type (
  chuboe_state_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT
);
COMMENT ON TABLE chuboe_state_type IS 'Table that defines the types of states of a request. State type is a set of standardized, cross-process representations of states that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often. See also: chuboe_state.';

-- Consider making this an enum since code will most likely be written against these values.
-- Here are reference values
INSERT INTO chuboe_state_type (chuboe_state_type_uu, name, description)
VALUES
  ('8cc3f867-8f75-4752-a91b-c92330979242', 'Start', 'Should only be one per process. This state is the state into which a new Request is placed when it is created.'),
  ('d5f2d251-4571-4638-823f-eecbf9fded5c', 'Normal', 'A regular state with no special designation.'),
  ('9a2b6a08-e094-4c12-8df6-67f7218b1fd7', 'Complete', 'A state signifying that any Request in this state have completed normally.'),
  ('35e12c60-8a35-4855-b3d1-e9ebd0e09450', 'Denied', 'A state signifying that any Request in this state has been denied (e.g. never got started and will not be worked on).'),
  ('345cceaf-4020-4621-b52d-a886c7bc57d8', 'Cancelled', 'A state signifying that any Request in this state has been cancelled (e.g. work was started but never completed).');

CREATE TABLE chuboe_activity_type (
  chuboe_activity_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT
);
COMMENT ON TABLE chuboe_activity_type IS 'Table that defines the types of activities that can result from a request transitioning from one state to another. Activity type is a set of standardized, cross-process representations of the activities that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often. See also: chuboe_activity.';

-- Consider making this an enum since code will most likely be written against these values.
-- Here are reference values
INSERT INTO chuboe_activity_type (chuboe_activity_type_uu, name, description)
VALUES
  ('6e2f1e78-31b5-4176-b986-6a0b16cfd58c', 'Add Note', 'Specifies that we should automatically add a note to a Request.'),
  ('d3ed8b7a-8b1b-4b1e-9b1e-1b1b1b1b1b1b', 'Send Email', 'Specifies that we should send an email to one or more recipients.'),
  ('a1b2c3d4-e5f6-7890-1234-5678901234ab', 'Add Stakeholders', 'Specifies that we should add one or more persons as Stakeholders on this request.'),
  ('1a2b3c4d-5e6f-7890-1234-5678901234ab', 'Remove Stakeholders', 'Specifies that we should remove one or more stakeholders from this request.');


CREATE TABLE chuboe_action_type (
  chuboe_action_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  is_parallel_action BOOLEAN DEFAULT FALSE, 
  description TEXT
);
COMMENT ON TABLE chuboe_action_type IS 'Table that defines the types of actions that can be performed. Action type is a set of standardized, cross-process representations of the actions that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often. See also: chuboe_action.';
-- todo: is_parallel_action => if true, then all actions must be active and complete to transition to next state. All actions must be of the same action type => is_parallel_action=TRUE. This concept represents parallel task management. Need to see if this concept is consistent with multiple actions of the same state having transitions to differing states.

-- Consider making this an enum since code will most likely be written against these values.
-- Here are reference values
INSERT INTO chuboe_action_type (chuboe_action_type_uu, name, description, is_parallel_action)
VALUES
  ('3d4e5f6a-7b8c-9d0e-1f2a-3b4c5d6e7f8a', 'Approve', 'The actioner is suggesting that the request should move to the next state.', false),
  ('3e513ff8-e50e-41fa-a529-6a2d33104fc3', 'Deny', 'The actioner is suggesting that the request should move to the previous state.', false),
  ('bd931ba8-28af-4ac8-a0f7-67c484e0e1ca', 'Execute', 'The actioner must perform a task then is suggesting that the request should move to the previous state.', false),
  ('22c9dd7e-18fa-4c75-9364-69aa05554446', 'Execute Parallel', 'The actioners must perform all tasks then is suggesting that the request should move to the previous state.', true),
  ('579d1832-35a9-4a49-8735-5042dbf123e2', 'Cancel', 'The actioner is suggesting that the request should move to the Cancelled state in the process.', false),
  ('a9d8c477-86db-4334-9b7b-0ef441d68088', 'Restart', 'The actioner suggesting that the request be moved back to the Start state in the process.', false),
  ('1b25c513-2f1d-4e7d-9691-f501d4ce460c', 'Resolve', 'The actioner is suggesting that the request be moved all the way to the Completed state.', false);


CREATE TABLE chuboe_process (
  chuboe_process_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  is_processed BOOLEAN NOT NULL, -- if true, process and process attribute tables cannot be modified, to make changes, clone the process.
  description TEXT
);
COMMENT ON TABLE chuboe_process IS 'Table that represents the starting point of workflow design and execution. Processes describe how to get things done and my whom. A process describes what is possible in a workflow scenario. A process acts as a hub to collect workflow data about users, requests, states, actions, and transitions. Most of the remaining workflow tables reference a process directly or indirectly.';

CREATE TABLE chuboe_group (
  chuboe_group_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  chuboe_process_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);
COMMENT ON TABLE chuboe_group IS 'Table that represents a collection of people. Processes can be created that support both "any" an "all" scenarios. An "any" scenario is where any one member of the group can act to create succes. An "all" scenaio is where all members of the group must act to create successs. A group can also be thought of as a role where anyone in the group is assumed to be able to act in that role. There is a relationship between groups and targets. Targets are cross-process. Groups are specific to a process. Targets can be linked to process groups inside a process. This is a process attribute table.';

CREATE TABLE chuboe_group_member_lnk (
  chuboe_group_member_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_group_uu UUID NOT NULL,
  chuboe_user_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_group_uu) REFERENCES chuboe_group(chuboe_group_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  UNIQUE (chuboe_group_uu, chuboe_user_uu)
);
COMMENT ON TABLE chuboe_group_member_lnk IS 'Table that links users to a process group.';
--todo: should members be added at the process level or the request level or both? Consider adding a chuboe_request_uu column to identify if the link was established at the request level. If this change is made, move this table definition below the chuboe_request table definition.

CREATE TABLE chuboe_process_admin_lnk (
  chuboe_process_admin_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_process_uu UUID NOT NULL,
  chuboe_user_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  UNIQUE (chuboe_process_uu, chuboe_user_uu)
);
COMMENT ON TABLE chuboe_process_admin_lnk IS 'Table that links users to processes as someone who can administer a particular process. Admins can create, update and delete processes';

CREATE TABLE chuboe_state (
  chuboe_state_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_state_type_uu UUID NOT NULL,
  chuboe_process_uu UUID NOT NULL,
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  FOREIGN KEY (chuboe_state_type_uu) REFERENCES chuboe_state_type(chuboe_state_type_uu),
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);
COMMENT ON TABLE chuboe_state IS 'Table that represents the states within a process. Note that we must first define the states of a process before we can create a request. This is a process attribute table.';

CREATE TABLE chuboe_action (
  chuboe_action_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_action_type_uu UUID NOT NULL,
  chuboe_process_uu UUID NOT NULL,
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  FOREIGN KEY (chuboe_action_type_uu) REFERENCES chuboe_action_type(chuboe_action_type_uu),
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);
COMMENT ON TABLE chuboe_action IS 'Table that represents the actions that can or should be performed in a specific process. The chuboe_action straddles both the concepts of "action" and "task". This is a request attribute table. This is a process attribute table.';

CREATE TABLE chuboe_request (
  chuboe_request_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_process_uu UUID NOT NULL,
  search_key VARCHAR(255) NOT NULL,
  date_requested TIMESTAMP NOT NULL,
  chuboe_user_uu UUID NOT NULL,
  chuboe_current_state_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  FOREIGN KEY (chuboe_current_state_uu) REFERENCES chuboe_state(chuboe_state_uu)
);
COMMENT ON TABLE chuboe_request IS 'Table that represents an instance of a process. A request is defined by its process. A request (and its "request attribute tables") describe all that occured to achieve the current state of an active request and that occured in a completed request. Note that the request maintains its current state as a column in the chuboe_request table. All other request attributes are maintains in "request attribute tables".';
--todo: the user_name column does not make any sense - or is not that useful

CREATE TABLE chuboe_request_note (
  chuboe_request_note_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID NOT NULL,
  chuboe_user_uu UUID NOT NULL,
  note TEXT NOT NULL,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu)
);
COMMENT ON TABLE chuboe_request_note IS 'Table that stores notes associated with a specific request and user. This is a request attribute table.';

CREATE TABLE chuboe_request_data (
  chuboe_request_data_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  value VARCHAR(255) NOT NULL,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu)
);
COMMENT ON TABLE chuboe_request_data IS 'Table that stores highly-variable data associated with a specific request. This is a request attribute table.';

CREATE TABLE chuboe_request_file (
  chuboe_request_file_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID NOT NULL,
  chuboe_user_uu UUID NOT NULL,
  date_uploaded TIMESTAMP NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_content BYTEA NOT NULL,
  mime_type VARCHAR(255) NOT NULL,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu)
);
COMMENT ON TABLE chuboe_request_file IS 'Table that stores files associated with a specific request and user. This is a request attribute table.';

CREATE TABLE chuboe_request_stakeholder_lnk (
  chuboe_request_stakeholder_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID NOT NULL,
  chuboe_user_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  UNIQUE (chuboe_request_uu, chuboe_user_uu)
);
COMMENT ON TABLE chuboe_request_stakeholder_lnk IS 'Table that links a user to a request thereby promoting the user to the role of stakeholder. A stakeholder is someone with a shared interest in a request life-cycle or resolution.  It is common for a stakeholder to request notifications when something about a request changes. This is a request attribute table.';
--todo: developer note: determine if this table is really needed. There is already a chuboe_group (role) table that can be used to create a stakeholder group.

CREATE TABLE chuboe_transition (
  chuboe_transition_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_current_state_uu UUID NOT NULL,
  chuboe_next_state_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_current_state_uu) REFERENCES chuboe_state(chuboe_state_uu),
  FOREIGN KEY (chuboe_next_state_uu) REFERENCES chuboe_state(chuboe_state_uu)
);
COMMENT ON TABLE chuboe_transition IS 'Table that defines the transitions between states in a process. Processes represent a flow chart, and to do that we need to be able to move requests between states. A transition is a path between two states that shows how a request can travel between them. Transitions are initiated as a result of one or more actions. Transitions are unique to a process.';

CREATE TABLE chuboe_activity (
  chuboe_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_activity_type_uu UUID NOT NULL,
  chuboe_process_uu UUID NOT NULL,
  search_key VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  FOREIGN KEY (chuboe_activity_type_uu) REFERENCES chuboe_activity_type(chuboe_activity_type_uu),
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);
COMMENT ON TABLE chuboe_activity IS 'Table that represents the activities that can be performed in a specific process. Activities are things that can happen as a result of a Request entering a state or following a transition. This is a request attribute table.';

CREATE TABLE chuboe_state_activity_lnk (
  chuboe_state_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_state_uu UUID NOT NULL,
  chuboe_activity_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_state_uu) REFERENCES chuboe_state(chuboe_state_uu),
  FOREIGN KEY (chuboe_activity_uu) REFERENCES chuboe_activity(chuboe_activity_uu),
  UNIQUE (chuboe_state_uu, chuboe_activity_uu)
);
COMMENT ON TABLE chuboe_state_activity_lnk IS 'Table that links activities to their respective states in a specific process. This table allows you to specify that the system should execute a specific activity as a result of entering a specific state.';
--todo: consider adding an attribute to this table dictating if the state is the to_be_state (entering) or the from_state (exiting). Currently exiting a state is silent.

CREATE TABLE chuboe_transition_activity_lnk (
  chuboe_transition_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_activity_uu UUID NOT NULL,
  chuboe_transition_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_activity_uu) REFERENCES chuboe_activity(chuboe_activity_uu),
  FOREIGN KEY (chuboe_transition_uu) REFERENCES chuboe_transition(chuboe_transition_uu),
  UNIQUE (chuboe_activity_uu, chuboe_transition_uu)
);
COMMENT ON TABLE chuboe_transition_activity_lnk IS 'Table that links activities to their respective transitions in a specific process. This table allows you to specify that the system should execute a specific activity as a result of performing a specific transition.';

CREATE TABLE chuboe_transition_action_lnk (
  chuboe_transition_action_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_transition_uu UUID NOT NULL,
  chuboe_action_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_transition_uu) REFERENCES chuboe_transition(chuboe_transition_uu),
  FOREIGN KEY (chuboe_action_uu) REFERENCES chuboe_action(chuboe_action_uu),
  UNIQUE (chuboe_transition_uu, chuboe_action_uu)
);
COMMENT ON TABLE chuboe_transition_action_lnk IS 'Table that links actions to transitions in the workflow process. This table defines what actions can be performed to instigate a particular transition';

CREATE TABLE chuboe_action_target_lnk (
  chuboe_action_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_action_uu UUID NOT NULL,
  chuboe_target_uu UUID NOT NULL,
  chuboe_group_uu UUID, --can be null - only accept when target => is_show_group=Y
  FOREIGN KEY (chuboe_action_uu) REFERENCES chuboe_action(chuboe_action_uu),
  FOREIGN KEY (chuboe_target_uu) REFERENCES chuboe_target(chuboe_target_uu),
  FOREIGN KEY (chuboe_group_uu) REFERENCES chuboe_group(chuboe_group_uu),
  UNIQUE (chuboe_action_uu, chuboe_target_uu)
);
COMMENT ON TABLE chuboe_action_target_lnk IS 'Table that links actions to their respective targets and associated groups. This tables acts as an access list to dictate who can perform what actions. If a group is the action target, then any member of the group can perform the action for it to be valid.';

CREATE TABLE chuboe_activity_target_lnk (
  chuboe_activity_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_activity_uu UUID NOT NULL,
  chuboe_target_uu UUID NOT NULL,
  chuboe_group_uu UUID, --can be null - only accept when target => is_show_group=Y
  FOREIGN KEY (chuboe_activity_uu) REFERENCES chuboe_activity(chuboe_activity_uu),
  FOREIGN KEY (chuboe_target_uu) REFERENCES chuboe_target(chuboe_target_uu),
  FOREIGN KEY (chuboe_group_uu) REFERENCES chuboe_group(chuboe_group_uu),
  UNIQUE (chuboe_activity_uu, chuboe_target_uu)
);
COMMENT ON TABLE chuboe_activity_target_lnk IS 'Table that links activities to their respective targets in the workflow process. This tables acts as an access list to dictate who can receive what activities. If a group is an activity target, then all members of the group receive the activity (e.g. everyone in the group gets an email).';

CREATE TABLE chuboe_request_action_log (
  chuboe_request_action_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID NOT NULL,
  chuboe_action_uu UUID NOT NULL,
  chuboe_transition_uu UUID NOT NULL,
  is_active BOOLEAN NOT NULL,
  is_processed BOOLEAN NOT NULL,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu),
  FOREIGN KEY (chuboe_action_uu) REFERENCES chuboe_action(chuboe_action_uu),
  FOREIGN KEY (chuboe_transition_uu) REFERENCES chuboe_transition(chuboe_transition_uu)
);
COMMENT ON TABLE chuboe_request_action_log IS 'Table that links actions to requests and their respective transitions. This is both 1. a record of all non-processed actions, and 2. a log of all actions per transition.';
