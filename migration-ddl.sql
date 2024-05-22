-- create the ddl artifacts to track workflow

-- considerations
-- need concept of a resolution
create schema if not exists private;
set search_path = private;

CREATE TABLE chuboe_process (
  chuboe_process_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT
);
COMMENT ON TABLE chuboe_process IS 'Table that represents the starting point of workflow design and execution. Processes describe how to get things done and my whom. A process describes what is possible in a workflow scenario. A process acts as a hub to collect workflow data about users, requests, states, actions, and transitions. Most of the remaining workflow tables reference a process directly or indirectly.';

CREATE TABLE chuboe_user (
  chuboe_user_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  last_name VARCHAR(255) NOT NULL,
  first_name VARCHAR(255) NOT NULL,
  email VARCHAR(255)
);
COMMENT ON TABLE chuboe_user IS 'Table that contains users. Note that users exist outside of a process. Any one user can participate in multiple processes.';

CREATE TABLE chuboe_group (
  chuboe_group_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  chuboe_process_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);
COMMENT ON TABLE chuboe_group IS 'Table that represents a collection of people. Processes can be created that support both "any" an "all" scenarios. An "any" scenario is where any one member of the group can act to create succes. An "all" scenaio is where all members of the group must act to create successs.';

CREATE TABLE chuboe_group_member_lnk (
  chuboe_group_member_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_group_uu UUID NOT NULL,
  chuboe_user_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_group_uu) REFERENCES chuboe_group(chuboe_group_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  UNIQUE (chuboe_group_uu, chuboe_user_uu)
);
COMMENT ON TABLE chuboe_group_member_lnk IS 'Table that links users to a process group.';

CREATE TABLE chuboe_process_admin_lnk (
  chuboe_process_admin_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_process_uu UUID NOT NULL,
  chuboe_user_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  UNIQUE (chuboe_process_uu, chuboe_user_uu)
);
COMMENT ON TABLE chuboe_process_admin_lnk IS 'Table that links users to processes as someone who can administer a particular process. Admins can create, update and delete processes';

CREATE TABLE chuboe_state_type (
  chuboe_state_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT
);
COMMENT ON TABLE chuboe_state_type IS 'Table that defines the different types of states of a request. The values in this table are near static, and they will not change often.';

-- Consider making this an enum since code will most likely be written against these values.
INSERT INTO chuboe_state_type (name, description)
VALUES
  ('Start', 'Should only be one per process. This state is the state into which a new Request is placed when it is created.'),
  ('Normal', 'A regular state with no special designation.'),
  ('Complete', 'A state signifying that any Request in this state have completed normally.'),
  ('Denied', 'A state signifying that any Request in this state has been denied (e.g. never got started and will not be worked on).'),
  ('Cancelled', 'A state signifying that any Request in this state has been cancelled (e.g. work was started but never completed).');

CREATE TABLE chuboe_state (
  chuboe_state_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_state_type_uu UUID NOT NULL,
  chuboe_process_uu UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  FOREIGN KEY (chuboe_state_type_uu) REFERENCES chuboe_state_type(chuboe_state_type_uu),
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);
COMMENT ON TABLE chuboe_state IS 'Table that represents the various states within a workflow process.';

CREATE TABLE chuboe_request (
  chuboe_request_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_process_uu UUID NOT NULL,
  title VARCHAR(255) NOT NULL,
  date_requested TIMESTAMP NOT NULL,
  chuboe_user_uu UUID NOT NULL,
  user_name VARCHAR(255) NOT NULL,
  chuboe_current_state_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  FOREIGN KEY (chuboe_current_state_uu) REFERENCES chuboe_state(chuboe_state_uu)
);
COMMENT ON TABLE chuboe_request IS 'Table that represents an instance of a process. A request is defined by its process. A request (and its assocated tables) describe all that occured to achieve the current state of an active request. A request (and its associated tables) describe what occured in a completed request. Note that the request maintains its current state.';

------

CREATE TABLE chuboe_action_type (
  chuboe_action_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT
);
COMMENT ON TABLE chuboe_action_type IS 'Table that defines the different types of actions that can be performed in any process. The values in this table are near static, and they will not change often.';

-- Consider making this an enum since code will most likely be written against these values.
INSERT INTO chuboe_action_type (name, description)
VALUES
  ('Approve', 'The actioner is suggesting that the request should move to the next state.'),
  ('Deny', 'The actioner is suggesting that the request should move to the previous state.'),
  ('Cancel', 'The actioner is suggesting that the request should move to the Cancelled state in the process.'),
  ('Restart', 'The actioner suggesting that the request be moved back to the Start state in the process.'),
  ('Resolve', 'The actioner is suggesting that the request be moved all the way to the Completed state.');

CREATE TABLE chuboe_action (
  chuboe_action_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_action_type_uu UUID NOT NULL,
  chuboe_process_uu UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  FOREIGN KEY (chuboe_action_type_uu) REFERENCES chuboe_action_type(chuboe_action_type_uu),
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);
COMMENT ON TABLE chuboe_action IS 'Table that represents the actions that can be performed in a specific process. This is a request attribute.';

CREATE TABLE chuboe_transition (
  chuboe_transition_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_current_state_uu UUID NOT NULL,
  chuboe_next_state_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_current_state_uu) REFERENCES chuboe_state(chuboe_state_uu),
  FOREIGN KEY (chuboe_next_state_uu) REFERENCES chuboe_state(chuboe_state_uu)
);
COMMENT ON TABLE chuboe_transition IS 'Table that defines the transitions between states in the workflow process.';
--Note: does this table need a link to the process for purposes of convenience? 

CREATE TABLE chuboe_transition_action_lnk (
  chuboe_transition_action_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_transition_uu UUID NOT NULL,
  chuboe_action_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_transition_uu) REFERENCES chuboe_transition(chuboe_transition_uu),
  FOREIGN KEY (chuboe_action_uu) REFERENCES chuboe_action(chuboe_action_uu),
  UNIQUE (chuboe_transition_uu, chuboe_action_uu)
);
COMMENT ON TABLE chuboe_transition_action_lnk IS 'Table that links actions to transitions in the workflow process.';
--Note: does this table need a link to the process for purposes of convenience? 

CREATE TABLE chuboe_target (
  chuboe_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT
);
COMMENT ON TABLE chuboe_target IS 'Table that represents the targets or recipients of actions in the workflow process.';

-- Consider making this an enum since code will most likely be written against these values.
INSERT INTO chuboe_target (name, description)
VALUES
  ('Requester', 'The user who initiated the request.'),
  ('Stakeholders', 'The users who are stakeholders of the request.'),
  ('Group Members', 'The users who are members of the group associated with the request.'),
  ('Process Admins', 'The users who are administrators of the process associated with the request.');

CREATE TABLE chuboe_action_target_lnk (
  chuboe_action_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_action_uu UUID NOT NULL,
  chuboe_target_uu UUID NOT NULL,
  chuboe_group_uu UUID, --can be null
  FOREIGN KEY (chuboe_action_uu) REFERENCES chuboe_action(chuboe_action_uu),
  FOREIGN KEY (chuboe_target_uu) REFERENCES chuboe_target(chuboe_target_uu),
  FOREIGN KEY (chuboe_group_uu) REFERENCES chuboe_group(chuboe_group_uu),
  UNIQUE (chuboe_action_uu, chuboe_target_uu)
);
COMMENT ON TABLE chuboe_action_target_lnk IS 'Table that links actions to their respective targets and associated groups.';

CREATE TABLE chuboe_activity_type (
  chuboe_activity_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT
);
COMMENT ON TABLE chuboe_activity_type IS 'Table that defines the different types of activities that can be performed in the workflow. The values in this table are near static, and they will not change often.';

-- Consider making this an enum since code will most likely be written against these values.
INSERT INTO chuboe_activity_type (name, description)
VALUES
  ('Add Note', 'Specifies that we should automatically add a note to a Request.'),
  ('Send Email', 'Specifies that we should send an email to one or more recipients.'),
  ('Add Stakeholders', 'Specifies that we should add one or more persons as Stakeholders on this request.'),
  ('Remove Stakeholders', 'Specifies that we should remove one or more stakeholders from this request.');

CREATE TABLE chuboe_activity (
  chuboe_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_activity_type_uu UUID NOT NULL,
  chuboe_process_uu UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  FOREIGN KEY (chuboe_activity_type_uu) REFERENCES chuboe_activity_type(chuboe_activity_type_uu),
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);
COMMENT ON TABLE chuboe_activity IS 'Table that represents the activities that can be performed in a specific process.';

CREATE TABLE chuboe_state_activity_lnk (
  chuboe_state_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_state_uu UUID NOT NULL,
  chuboe_activity_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_state_uu) REFERENCES chuboe_state(chuboe_state_uu),
  FOREIGN KEY (chuboe_activity_uu) REFERENCES chuboe_activity(chuboe_activity_uu),
  UNIQUE (chuboe_state_uu, chuboe_activity_uu)
);
COMMENT ON TABLE chuboe_state_activity_lnk IS 'Table that links activities to their respective states in the workflow process.';

CREATE TABLE chuboe_activity_target_lnk (
  chuboe_activity_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_activity_uu UUID NOT NULL,
  chuboe_target_uu UUID NOT NULL,
  chuboe_group_uu UUID, --can be null
  FOREIGN KEY (chuboe_activity_uu) REFERENCES chuboe_activity(chuboe_activity_uu),
  FOREIGN KEY (chuboe_target_uu) REFERENCES chuboe_target(chuboe_target_uu),
  FOREIGN KEY (chuboe_group_uu) REFERENCES chuboe_group(chuboe_group_uu),
  UNIQUE (chuboe_activity_uu, chuboe_target_uu)
);
COMMENT ON TABLE chuboe_activity_target_lnk IS 'Table that links activities to their respective targets in the workflow process.';

CREATE TABLE chuboe_transition_activity_lnk (
  chuboe_transition_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_activity_uu UUID NOT NULL,
  chuboe_transition_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_activity_uu) REFERENCES chuboe_activity(chuboe_activity_uu),
  FOREIGN KEY (chuboe_transition_uu) REFERENCES chuboe_transition(chuboe_transition_uu),
  UNIQUE (chuboe_activity_uu, chuboe_transition_uu)
);
COMMENT ON TABLE chuboe_transition_activity_lnk IS 'Table that links activities to transitions in the workflow process.';

CREATE TABLE chuboe_request_note (
  chuboe_request_note_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID NOT NULL,
  chuboe_user_uu UUID NOT NULL,
  note TEXT NOT NULL,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu)
);
COMMENT ON TABLE chuboe_request_note IS 'Table that stores notes associated with a specific request and user. This is a request attribute.';

CREATE TABLE chuboe_request_data (
  chuboe_request_data_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  value VARCHAR(255) NOT NULL,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu)
);
COMMENT ON TABLE chuboe_request_data IS 'Table that stores additional data associated with a specific request. This is a request attribute.';

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
COMMENT ON TABLE chuboe_request_file IS 'Table that stores files associated with a specific request and user. This is a request attribute.';

CREATE TABLE chuboe_request_action_lnk (
  chuboe_request_action_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID NOT NULL,
  chuboe_action_uu UUID NOT NULL,
  chuboe_transition_uu UUID NOT NULL,
  is_active BOOLEAN NOT NULL,
  is_complete BOOLEAN NOT NULL,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu),
  FOREIGN KEY (chuboe_action_uu) REFERENCES chuboe_action(chuboe_action_uu),
  FOREIGN KEY (chuboe_transition_uu) REFERENCES chuboe_transition(chuboe_transition_uu),
  UNIQUE (chuboe_request_uu, chuboe_action_uu, chuboe_transition_uu)
);
COMMENT ON TABLE chuboe_request_action_lnk IS 'Table that links actions to requests and their respective transitions.';

CREATE TABLE chuboe_request_stakeholder_lnk (
  chuboe_request_stakeholder_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID NOT NULL,
  chuboe_user_uu UUID NOT NULL,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  UNIQUE (chuboe_request_uu, chuboe_user_uu)
);
COMMENT ON TABLE chuboe_request_stakeholder_lnk IS 'Table that links stakeholders (users) to their respective requests. This is a request attribute.';
