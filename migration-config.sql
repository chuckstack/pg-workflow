-- Static data used to create workflows.
set search_path = private;

INSERT INTO chuboe_state_type (name, description)
VALUES
  ('Start', 'Should only be one per process. This state is the state into which a new Request is placed when it is created.'),
  ('Normal', 'A regular state with no special designation.'),
  ('Complete', 'A state signifying that any Request in this state have completed normally.'),
  ('Denied', 'A state signifying that any Request in this state has been denied (e.g. never got started and will not be worked on).'),
  ('Cancelled', 'A state signifying that any Request in this state has been cancelled (e.g. work was started but never completed).');

-- Insert initial chuboe_action_type records
INSERT INTO chuboe_action_type (name, description)
VALUES
  ('Approve', 'The actioner is suggesting that the request should move to the next state.'),
  ('Deny', 'The actioner is suggesting that the request should move to the previous state.'),
  ('Cancel', 'The actioner is suggesting that the request should move to the Cancelled state in the process.'),
  ('Restart', 'The actioner suggesting that the request be moved back to the Start state in the process.'),
  ('Resolve', 'The actioner is suggesting that the request be moved all the way to the Completed state.');

-- Insert initial chuboe_activity_type records
INSERT INTO chuboe_activity_type (name, description)
VALUES
  ('Add Note', 'Specifies that we should automatically add a note to a Request.'),
  ('Send Email', 'Specifies that we should send an email to one or more recipients.'),
  ('Add Stakeholders', 'Specifies that we should add one or more persons as Stakeholders on this request.'),
  ('Remove Stakeholders', 'Specifies that we should remove one or more stakeholders from this request.');

-- Insert initial chuboe_target records
INSERT INTO chuboe_target (name, description)
VALUES
  ('Requester', 'The user who initiated the request.'),
  ('Stakeholders', 'The users who are stakeholders of the request.'),
  ('Group Members', 'The users who are members of the group associated with the request.'),
  ('Process Admins', 'The users who are administrators of the process associated with the request.');
