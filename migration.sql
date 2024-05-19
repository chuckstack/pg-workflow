CREATE TABLE chuboe_user (
  chuboe_user_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  last_name VARCHAR(255),
  first_name VARCHAR(255)
);

CREATE TABLE chuboe_state_type (
  chuboe_state_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255)
);

CREATE TABLE chuboe_process (
  chuboe_process_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255)
);

CREATE TABLE chuboe_group (
  chuboe_group_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255),
  chuboe_process_uu UUID,
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);

CREATE TABLE chuboe_group_member_lnk (
  chuboe_group_member_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_group_uu UUID,
  chuboe_user_uu UUID,
  FOREIGN KEY (chuboe_group_uu) REFERENCES chuboe_group(chuboe_group_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  UNIQUE (chuboe_group_uu, chuboe_user_uu)
);

CREATE TABLE chuboe_process_admin_lnk (
  chuboe_process_admin_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_process_uu UUID,
  chuboe_user_uu UUID,
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  UNIQUE (chuboe_process_uu, chuboe_user_uu)
);

CREATE TABLE chuboe_state (
  chuboe_state_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_state_type_uu UUID,
  chuboe_process_uu UUID,
  name VARCHAR(255),
  description TEXT,
  FOREIGN KEY (chuboe_state_type_uu) REFERENCES chuboe_state_type(chuboe_state_type_uu),
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);

CREATE TABLE chuboe_action_type (
  chuboe_action_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255)
);

CREATE TABLE chuboe_action (
  chuboe_action_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_action_type_uu UUID,
  chuboe_process_uu UUID,
  name VARCHAR(255),
  description TEXT,
  FOREIGN KEY (chuboe_action_type_uu) REFERENCES chuboe_action_type(chuboe_action_type_uu),
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);

CREATE TABLE chuboe_transition (
  chuboe_transition_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_current_state_uu UUID,
  chuboe_next_state_uu UUID,
  FOREIGN KEY (chuboe_current_state_uu) REFERENCES chuboe_state(chuboe_state_uu),
  FOREIGN KEY (chuboe_next_state_uu) REFERENCES chuboe_state(chuboe_state_uu)
);

CREATE TABLE chuboe_transition_action_lnk (
  chuboe_transition_action_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_transition_uu UUID,
  chuboe_action_uu UUID,
  FOREIGN KEY (chuboe_transition_uu) REFERENCES chuboe_transition(chuboe_transition_uu),
  FOREIGN KEY (chuboe_action_uu) REFERENCES chuboe_action(chuboe_action_uu),
  UNIQUE (chuboe_transition_uu, chuboe_action_uu)
);

CREATE TABLE chuboe_target (
  chuboe_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255),
  description TEXT
);

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

CREATE TABLE chuboe_activity_type (
  chuboe_activity_type_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255)
);

CREATE TABLE chuboe_activity (
  chuboe_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_activity_type_uu UUID,
  chuboe_process_uu UUID,
  name VARCHAR(255),
  description TEXT,
  FOREIGN KEY (chuboe_activity_type_uu) REFERENCES chuboe_activity_type(chuboe_activity_type_uu),
  FOREIGN KEY (chuboe_process_uu) REFERENCES chuboe_process(chuboe_process_uu)
);

CREATE TABLE chuboe_state_activity_lnk (
  chuboe_state_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_state_uu UUID,
  chuboe_activity_uu UUID,
  FOREIGN KEY (chuboe_state_uu) REFERENCES chuboe_state(chuboe_state_uu),
  FOREIGN KEY (chuboe_activity_uu) REFERENCES chuboe_activity(chuboe_activity_uu),
  UNIQUE (chuboe_state_uu, chuboe_activity_uu)
);

CREATE TABLE chuboe_activity_target_lnk (
  chuboe_activity_target_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_activity_uu UUID,
  chuboe_target_uu UUID,
  FOREIGN KEY (chuboe_activity_uu) REFERENCES chuboe_activity(chuboe_activity_uu),
  FOREIGN KEY (chuboe_target_uu) REFERENCES chuboe_target(chuboe_target_uu),
  UNIQUE (chuboe_activity_uu, chuboe_target_uu)
);

CREATE TABLE chuboe_transition_activity_lnk (
  chuboe_transition_activity_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_activity_uu UUID,
  chuboe_transition_uu UUID,
  FOREIGN KEY (chuboe_activity_uu) REFERENCES chuboe_activity(chuboe_activity_uu),
  FOREIGN KEY (chuboe_transition_uu) REFERENCES chuboe_transition(chuboe_transition_uu),
  UNIQUE (chuboe_activity_uu, chuboe_transition_uu)
);

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

CREATE TABLE chuboe_request_note (
  chuboe_request_note_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID,
  chuboe_user_uu UUID,
  note TEXT,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu)
);

CREATE TABLE chuboe_request_data (
  chuboe_request_data_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID,
  name VARCHAR(255),
  value VARCHAR(255),
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu)
);

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

CREATE TABLE chuboe_request_stakeholder_lnk (
  chuboe_request_stakeholder_uu UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chuboe_request_uu UUID,
  chuboe_user_uu UUID,
  FOREIGN KEY (chuboe_request_uu) REFERENCES chuboe_request(chuboe_request_uu),
  FOREIGN KEY (chuboe_user_uu) REFERENCES chuboe_user(chuboe_user_uu),
  UNIQUE (chuboe_request_uu, chuboe_user_uu)
);
