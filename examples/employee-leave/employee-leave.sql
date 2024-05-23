--The purpose of this file is to help you learn this workflow framework through the use of examples. To do this, we need sample data. Let's do the following: 
--1. create an example scenario to use as a teaching tool, 
--2. create sql statements to enter the data. 
--3. discuss what you are inserting/updating and why.

----------------------------------------------------------------------------
--Example Scenario: Employee Leave Request Workflow
----------------------------------------------------------------------------

--In this scenario, we'll design a workflow process for managing employee leave requests. The process will involve the following steps:

--1. An employee submits a leave request.
--2. The employee's manager reviews the request and either approves or denies it.
--3. If approved, the HR department processes the request and marks it as complete.
--4. If denied, the employee is notified, and the request is marked as denied.

--SQL Statements:

set search_path = private;

--1. Insert sample users:

INSERT INTO chuboe_user (first_name, last_name, email)
VALUES
  ('John', 'Doe', 'john.doe@example.com'),
  ('Jane', 'Smith', 'jane.smith@example.com'),
  ('Michael', 'Johnson', 'michael.johnson@example.com'),
  ('Emily', 'Davis', 'emily.davis@example.com');

--Discussion: We insert four sample users into the chuboe_user table to represent employees and managers involved in the leave request process.

--2. Insert a sample process:

INSERT INTO chuboe_process (name, is_processed, description)
VALUES ('Employee Leave Request', false, 'Process for managing employee leave requests');

--Discussion: We create a new process named "Employee Leave Request" to represent the workflow for handling leave requests.

--3. Insert sample states:

INSERT INTO chuboe_state (chuboe_state_type_uu, chuboe_process_uu, name, description)
VALUES
  ((SELECT chuboe_state_type_uu FROM chuboe_state_type WHERE name = 'Start'), (SELECT chuboe_process_uu FROM chuboe_process WHERE name = 'Employee Leave Request'), 'New Request', 'Employee submits a new leave request'),
  ((SELECT chuboe_state_type_uu FROM chuboe_state_type WHERE name = 'Normal'), (SELECT chuboe_process_uu FROM chuboe_process WHERE name = 'Employee Leave Request'), 'Manager Review', 'Manager reviews the leave request'),
  ((SELECT chuboe_state_type_uu FROM chuboe_state_type WHERE name = 'Complete'), (SELECT chuboe_process_uu FROM chuboe_process WHERE name = 'Employee Leave Request'), 'Request Approved', 'Leave request is approved and processed'),
  ((SELECT chuboe_state_type_uu FROM chuboe_state_type WHERE name = 'Denied'), (SELECT chuboe_process_uu FROM chuboe_process WHERE name = 'Employee Leave Request'), 'Request Denied', 'Leave request is denied');

--Discussion: We insert four states into the chuboe_state table, representing the different stages of the leave request process. We use subqueries to fetch the appropriate chuboe_state_type_uu and chuboe_process_uu values based on their names.

--4. Insert sample actions:

INSERT INTO chuboe_action (chuboe_action_type_uu, chuboe_process_uu, name, description)
VALUES
  ((SELECT chuboe_action_type_uu FROM chuboe_action_type WHERE name = 'Approve'), (SELECT chuboe_process_uu FROM chuboe_process WHERE name = 'Employee Leave Request'), 'Approve Request', 'Manager approves the leave request'),
  ((SELECT chuboe_action_type_uu FROM chuboe_action_type WHERE name = 'Deny'), (SELECT chuboe_process_uu FROM chuboe_process WHERE name = 'Employee Leave Request'), 'Deny Request', 'Manager denies the leave request');

--Discussion: We insert two actions into the chuboe_action table, representing the possible actions a manager can take on a leave request: approve or deny.

--5. Insert sample transitions:

INSERT INTO chuboe_transition (chuboe_current_state_uu, chuboe_next_state_uu)
VALUES
  ((SELECT chuboe_state_uu FROM chuboe_state WHERE name = 'New Request'), (SELECT chuboe_state_uu FROM chuboe_state WHERE name = 'Manager Review')),
  ((SELECT chuboe_state_uu FROM chuboe_state WHERE name = 'Manager Review'), (SELECT chuboe_state_uu FROM chuboe_state WHERE name = 'Request Approved')),
  ((SELECT chuboe_state_uu FROM chuboe_state WHERE name = 'Manager Review'), (SELECT chuboe_state_uu FROM chuboe_state WHERE name = 'Request Denied'));

--Discussion: We insert three transitions into the chuboe_transition table, defining the possible paths a leave request can take between states. The first transition moves the request from "New Request" to "Manager Review". The second transition moves the request from "Manager Review" to "Request Approved" if approved, while the third transition moves it to "Request Denied" if denied.

--6. Insert sample groups:

INSERT INTO chuboe_group (name, description, chuboe_process_uu)
VALUES
  ('Employees', 'All employees in the organization', (SELECT chuboe_process_uu FROM chuboe_process WHERE name = 'Employee Leave Request')),
  ('Managers', 'All managers in the organization', (SELECT chuboe_process_uu FROM chuboe_process WHERE name = 'Employee Leave Request')),
  ('HR', 'Human Resources department', (SELECT chuboe_process_uu FROM chuboe_process WHERE name = 'Employee Leave Request'));

--Discussion: We insert three groups into the chuboe_group table, representing the different roles involved in the leave request process: employees, managers, and HR.

--7. Insert sample group members:

INSERT INTO chuboe_group_member_lnk (chuboe_group_uu, chuboe_user_uu)
VALUES
  ((SELECT chuboe_group_uu FROM chuboe_group WHERE name = 'Employees'), (SELECT chuboe_user_uu FROM chuboe_user WHERE email = 'john.doe@example.com')),
  ((SELECT chuboe_group_uu FROM chuboe_group WHERE name = 'Employees'), (SELECT chuboe_user_uu FROM chuboe_user WHERE email = 'jane.smith@example.com')),
  ((SELECT chuboe_group_uu FROM chuboe_group WHERE name = 'Managers'), (SELECT chuboe_user_uu FROM chuboe_user WHERE email = 'michael.johnson@example.com')),
  ((SELECT chuboe_group_uu FROM chuboe_group WHERE name = 'HR'), (SELECT chuboe_user_uu FROM chuboe_user WHERE email = 'emily.davis@example.com'));

--Discussion: We insert group members into the chuboe_group_member_lnk table, assigning users to their respective groups based on their roles.

--This concludes creating process. Now let's start working on inserting the request...

--8. Insert a new request:

INSERT INTO chuboe_request (chuboe_process_uu, title, date_requested, chuboe_user_uu, user_name, chuboe_current_state_uu)
VALUES (
  (SELECT chuboe_process_uu FROM chuboe_process WHERE name = 'Employee Leave Request'),
  'John Doe Leave Request',
  NOW(),
  (SELECT chuboe_user_uu FROM chuboe_user WHERE email = 'john.doe@example.com'),
  (SELECT CONCAT(first_name, ' ', last_name) FROM chuboe_user WHERE email = 'john.doe@example.com'),
  (SELECT chuboe_state_uu FROM chuboe_state WHERE name = 'New Request' AND chuboe_process_uu = (SELECT chuboe_process_uu FROM chuboe_process WHERE name = 'Employee Leave Request'))
);

--Discussion: This SQL statement inserts a new request into the chuboe_request table. Here's what each part of the statement does:

--- We select the chuboe_process_uu for the 'Employee Leave Request' process using a subquery.
--- We provide a title for the request, in this case, 'John Doe Leave Request'.
--- We use the NOW() function to set the date_requested to the current timestamp.
--- We select the chuboe_user_uu for the user with the email 'john.doe@example.com' using a subquery.
--- We concatenate the first_name and last_name of the user to set the user_name value.
--- We select the chuboe_state_uu for the 'New Request' state within the 'Employee Leave Request' process using a subquery. This sets the initial state of the request.

--By executing this SQL statement, a new request will be inserted into the chuboe_request table with the specified process, title, requester, and initial state. This represents an employee submitting a new leave request.

--2. Retrieve the inserted request:

SELECT *
FROM chuboe_request
WHERE title = 'John Doe Leave Request';

--Discussion: After inserting the request, you can retrieve it from the chuboe_request table to verify that it was successfully inserted. This SQL statement selects all columns from the chuboe_request table where the title matches 'John Doe Leave Request'.

--This example scenario and the accompanying SQL statements provide a starting point for teaching others how to use the workflow management framework. You can demonstrate how to define processes, states, actions, transitions, and groups, and how to assign users to different roles within the workflow.

--Remember to adapt the example and SQL statements to fit your specific teaching context and audience.

