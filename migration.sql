create schema if not exists private;
set search_path = private;

CREATE TABLE chuboe_user (
  chuboe_user_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  last_name VARCHAR(255),
  first_name VARCHAR(255)
);
COMMENT ON TABLE chuboe_user IS 'Table that contains users of the workflow.';

CREATE TABLE chuboe_state_type (
  chuboe_state_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255)
);
COMMENT ON TABLE chuboe_state_type IS 'Table that defines the different types of states in the workflow process.';

CREATE TABLE chuboe_process (
  chuboe_process_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255)
);
COMMENT ON TABLE chuboe_process IS 'Table that holds the collection of all process data that is unique to a group of users and how they want their Requests approved';

CREATE TABLE chuboe_group (
  chuboe_group_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255),
  chuboe_process_uu UUID,
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);
COMMENT ON TABLE chuboe_group IS 'Table that represents groups of users associated with a specific process.';

CREATE TABLE chuboe_group_member_lnk (
  chuboe_group_member_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_group_uu UUID,
  chuboe_user_uu UUID,
  FOREIGN KEY (chuboe_group_uu) REFERENCES chuboe_group(chuboe_group_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  UNIQUE (chuboe_group_uu, chuboe_user_uu)
);
COMMENT ON TABLE chuboe_group_member_lnk IS 'Table that links users to their respective groups.';

CREATE TABLE chuboe_process_admin_lnk (
  chuboe_process_admin_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_process_uu UUID,
  chuboe_user_uu UUID,
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  UNIQUE (chuboe_process_uu, chuboe_user_uu)
);
COMMENT ON TABLE chuboe_process_admin_lnk IS 'Table that links users to processes as someone who can administer a particular process. Admins can create, update and delete processes';

CREATE TABLE chuboe_state (
  chuboe_state_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_state_type_uu UUID,
  chuboe_process_uu UUID,
  name VARCHAR(255),
  description TEXT,
  FOREIGN KEY (chuboe_state_type_uu) REFERENCES chuboe_state_type(chuboe_state_type_uu),
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);
COMMENT ON TABLE chuboe_state IS 'Table that represents the various states within a workflow process.';

CREATE TABLE chuboe_action_type (
  chuboe_action_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255)
);
COMMENT ON TABLE chuboe_action_type IS 'Table that defines the different types of actions that can be performed in the workflow.';

CREATE TABLE chuboe_action (
  chuboe_action_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_action_type_uu UUID,
  chuboe_process_uu UUID,
  name VARCHAR(255),
  description TEXT,
  FOREIGN KEY (chuboe_action_type_uu) REFERENCES chuboe_action_type(chuboe_action_type_uu),
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);
COMMENT ON TABLE chuboe_action IS 'Table that represents the actions that can be performed in a specific process.';

CREATE TABLE chuboe_transition (
  chuboe_transition_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_current_state_uu UUID,
  chuboe_next_state_uu UUID,
  FOREIGN KEY (chuboe_current_state_uu) REFERENCES chuboe_state(chuboe_state_uu),
  FOREIGN KEY (chuboe_next_state_uu) REFERENCES chuboe_state(chuboe_state_uu)
);
COMMENT ON TABLE chuboe_transition IS 'Table that defines the transitions between states in the workflow process.';

CREATE TABLE chuboe_transition_action_lnk (
  chuboe_transition_action_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_transition_uu UUID,
  chuboe_action_uu UUID,
  FOREIGN KEY (chuboe_transition_uu) REFERENCES chuboe_transition(chuboe_transition_uu),
  FOREIGN KEY (chuboe_action_uu) REFERENCES chuboe_action(chuboe_action_uu),
  UNIQUE (chuboe_transition_uu, chuboe_action_uu)
);
COMMENT ON TABLE chuboe_transition_action_lnk IS 'Table that links actions to transitions in the workflow process.';

CREATE TABLE chuboe_target (
  chuboe_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255),
  description TEXT
);
COMMENT ON TABLE chuboe_target IS 'Table that represents the targets or recipients of actions in the workflow process.';

CREATE TABLE chuboe_action_target_lnk (
  chuboe_action_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_action_uu UUID,
  chuboe_target_uu UUID,
  chuboe_group_uu UUID,
  FOREIGN KEY (chuboe_action_uu) REFERENCES chuboe_action(chuboe_action_uu),
  FOREIGN KEY (chuboe_target_uu) REFERENCES chuboe_target(chuboe_target_uu),
  FOREIGN KEY (chuboe_group_uu) REFERENCES chuboe_group(chuboe_group_uu),
  UNIQUE (chuboe_action_uu, chuboe_target_uu)
);
COMMENT ON TABLE chuboe_action_target_lnk IS 'Table that links actions to their respective targets and associated groups.';

CREATE TABLE chuboe_activity_type (
  chuboe_activity_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255)
);
COMMENT ON TABLE chuboe_activity_type IS 'Table that defines the different types of activities that can be performed in the workflow.';

CREATE TABLE chuboe_activity (
  chuboe_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_activity_type_uu UUID,
  chuboe_process_uu UUID,
  name VARCHAR(255),
  description TEXT,
  FOREIGN KEY (chuboe_activity_type_uu) REFERENCES chuboe_activity_type(chuboe_activity_type_uu),
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);
COMMENT ON TABLE chuboe_activity IS 'Table that represents the activities that can be performed in a specific process.';

CREATE TABLE chuboe_state_activity_lnk (
  chuboe_state_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_state_uu UUID,
  chuboe_activity_uu UUID,
  FOREIGN KEY (chuboe_state_uu) REFERENCES chuboe_state(chuboe_state_uu),
  FOREIGN KEY (chuboe_activity_uu) REFERENCES chuboe_activity(chuboe_activity_uu),
  UNIQUE (chuboe_state_uu, chuboe_activity_uu)
);
COMMENT ON TABLE chuboe_state_activity_lnk IS 'Table that links activities to their respective states in the workflow process.';

CREATE TABLE chuboe_activity_target_lnk (
  chuboe_activity_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_activity_uu UUID,
  chuboe_target_uu UUID,
  FOREIGN KEY (chuboe_activity_uu) REFERENCES chuboe_activity(chuboe_activity_uu),
  FOREIGN KEY (chuboe_target_uu) REFERENCES chuboe_target(chuboe_target_uu),
  UNIQUE (chuboe_activity_uu, chuboe_target_uu)
);
COMMENT ON TABLE chuboe_activity_target_lnk IS 'Table that links activities to their respective targets in the workflow process.';

CREATE TABLE chuboe_transition_activity_lnk (
  chuboe_transition_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_activity_uu UUID,
  chuboe_transition_uu UUID,
  FOREIGN KEY (chuboe_activity_uu) REFERENCES chuboe_activity(chuboe_activity_uu),
  FOREIGN KEY (chuboe_transition_uu) REFERENCES chuboe_transition(chuboe_transition_uu),
  UNIQUE (chuboe_activity_uu, chuboe_transition_uu)
);
COMMENT ON TABLE chuboe_transition_activity_lnk IS 'Table that links activities to transitions in the workflow process.';

CREATE TABLE chuboe_request (
  chuboe_request_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_process_uu UUID,
  title VARCHAR(255),
  date_requested TIMESTAMP,
  chuboe_user_uu UUID,
  user_name VARCHAR(255),
  chuboe_current_state_uu UUID,
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  FOREIGN KEY (chuboe_current_state_uu) REFERENCES chuboe_state(chuboe_state_uu)
);
COMMENT ON TABLE chuboe_request IS 'Table that holds the instances (Requests) of a Process.';

CREATE TABLE chuboe_request_note (
  chuboe_request_note_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID,
  chuboe_user_uu UUID,
  note TEXT,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu)
);
COMMENT ON TABLE chuboe_request_note IS 'Table that stores notes associated with a specific request and user.';

CREATE TABLE chuboe_request_data (
  chuboe_request_data_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID,
  name VARCHAR(255),
  value VARCHAR(255),
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu)
);
COMMENT ON TABLE chuboe_request_data IS 'Table that stores additional data associated with a specific request.';

CREATE TABLE chuboe_request_file (
  chuboe_request_file_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID,
  chuboe_user_uu UUID,
  date_uploaded TIMESTAMP,
  file_name VARCHAR(255),
  file_content BYTEA,
  mime_type VARCHAR(255),
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu)
);
COMMENT ON TABLE chuboe_request_file IS 'Table that stores files associated with a specific request and user.';

CREATE TABLE chuboe_request_action_lnk (
  chuboe_request_action_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID,
  chuboe_action_uu UUID,
  chuboe_transition_uu UUID,
  is_active BOOLEAN,
  is_complete BOOLEAN,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu),
  FOREIGN KEY (chuboe_action_uu) REFERENCES chuboe_action(chuboe_action_uu),
  FOREIGN KEY (chuboe_transition_uu) REFERENCES chuboe_transition(chuboe_transition_uu),
  UNIQUE (chuboe_request_uu, chuboe_action_uu, chuboe_transition_uu)
);
COMMENT ON TABLE chuboe_request_action_lnk IS 'Table that links actions to requests and their respective transitions.';

CREATE TABLE chuboe_request_stakeholder_lnk (
  chuboe_request_stakeholder_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID,
  chuboe_user_uu UUID,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  UNIQUE (chuboe_request_uu, chuboe_user_uu)
);
COMMENT ON TABLE chuboe_request_stakeholder_lnk IS 'Table that links stakeholders (users) to their respective requests.';
