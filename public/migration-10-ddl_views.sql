CREATE VIEW api_user AS SELECT * FROM stack_user;
COMMENT ON VIEW api_user IS 'Table that contains users. Users are a cross-process represenation of actors in a workflow. Any one user can participate in multiple processes. See also: stack_wf_group.';

CREATE VIEW api_process_type AS SELECT * FROM stack_wf_process_type;
COMMENT ON VIEW api_process_type IS 'Table that represents the types of processes. A process type is a set of standardized, cross-process representations of the types of processes that exist. The purpose of this table is to provide reporting options for the resulting workflow processes and requests. The values in this table are near static, and they will not change often.';

CREATE VIEW api_target_type AS SELECT * FROM stack_wf_target_type;
COMMENT ON VIEW api_target_type IS 'Table that represents the types of targets or recipients of actions. A target type is a set of standardized, cross-process representations of groups that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often.';

CREATE VIEW api_state_type AS SELECT * FROM stack_wf_state_type;
COMMENT ON VIEW api_state_type IS 'Table that defines the types of states of a request. It is important to note the difference between state and resolution. For example, a state might be "completed" but the resolution might be "Successful" or "failed". State type is a set of standardized, cross-process representations of states that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often. See also: stack_wf_state.';

CREATE VIEW api_resolution_type AS SELECT * FROM stack_wf_resolution_type;
COMMENT ON VIEW api_resolution_type IS 'Table that defines the types of resolutions of a request. It is important to note the difference between state and resolution. For example, a state might be "completed" but the resolution might be "Successful" or "failed". Resolution type is a set of standardized, cross-process representations of resolutions that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often. See also: stack_wf_resolution.';

CREATE VIEW api_activity_type AS SELECT * FROM stack_wf_activity_type;
COMMENT ON VIEW api_activity_type IS 'Table that defines the types of activities that can result from a request transitioning from one state to another. You might notice there is no concept of a task in this design. The activity is what should be done. The stack_wf_request_action_history table represent what pending task is to be done or what task was done. Activity type is a set of standardized, cross-process representations of the activities that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often. See also: stack_wf_activity.';

CREATE VIEW api_action_type AS SELECT * FROM stack_wf_action_type;
COMMENT ON VIEW api_action_type IS 'Table that defines the types of actions that can be performed to instigate a change in state. Action type is a set of standardized, cross-process representations of the actions that might exist across multiple processes. The purpose of this table is to provide developers the least number of options to code scenarios against. The values in this table are near static, and they will not change often. See also: stack_wf_action.';

CREATE VIEW api_process AS SELECT * FROM stack_wf_process;
COMMENT ON VIEW api_process IS 'Table that represents the starting point of workflow design and execution. Processes describe how to get things done and my whom. A process describes what is possible in a workflow scenario. A process acts as a hub to collect workflow data about users, requests, states, actions, and transitions. Most of the remaining workflow tables reference a process directly or indirectly.';

CREATE VIEW api_group AS SELECT * FROM stack_wf_group;
COMMENT ON VIEW api_group IS 'Table that represents a collection of people. Processes can be created that support both "any" an "all" scenarios. An "any" scenario is where any one member of the group can act to create succes. An "all" scenaio is where all members of the group must act to create successs. A group can also be thought of as a role where anyone in the group is assumed to be able to act in that role. There is a relationship between groups and targets. Targets are cross-process. Groups are specific to a process. Targets can be linked to process groups inside a process. This is a process attribute table.';

CREATE VIEW api_group_member_lnk AS SELECT * FROM stack_wf_group_member_lnk;
COMMENT ON VIEW api_group_member_lnk IS 'Table that links users to a process group.';

CREATE VIEW api_process_admin_lnk AS SELECT * FROM stack_wf_process_admin_lnk;
COMMENT ON VIEW api_process_admin_lnk IS 'Table that links users to processes as someone who can administer a particular process. Admins can create, update and delete processes';

CREATE VIEW api_target AS SELECT * FROM stack_wf_target;
COMMENT ON VIEW api_target IS 'Table that represents the targets within a process. Note that we must first define the targets of a process before we can create a request. This is a process attribute table.';

CREATE VIEW api_state AS SELECT * FROM stack_wf_state;
COMMENT ON VIEW api_state IS 'Table that represents the states within a process. Note that we must first define the states of a process before we can create a request. This is a process attribute table.';

CREATE VIEW api_resolution AS SELECT * FROM stack_wf_resolution;
COMMENT ON VIEW api_resolution IS 'Table that represents the resolutions within a process. Note that we must first define the resolutions of a process before we can create a request. This is a process attribute table.';

CREATE VIEW api_action AS SELECT * FROM stack_wf_action;
COMMENT ON VIEW api_action IS 'Table that represents the actions that can or should be performed to change the state in a specific request. This is a request attribute table. This is a process attribute table.';

CREATE VIEW api_transition AS SELECT * FROM stack_wf_transition;
COMMENT ON VIEW api_transition IS 'Table that defines the transitions between states in a process. Processes represent a flow chart, and to do that we need to be able to move requests between states. A transition is a path between two states that shows how a request can travel between them. Note that setting a resolution is optional. If you include resolutions, you might need to specify the same transition multiple times (once per resolution). These records will act as options for the user and help them automatically set the resolution based on their choice. Transitions are initiated as a result of one or more actions. Transitions are unique to a process.';

CREATE VIEW api_request AS SELECT * FROM stack_wf_request;
COMMENT ON VIEW api_request IS 'Table that represents an instance of a process. A request is defined by its process. A request (and its "request attribute tables") describe all that occured to achieve the current state of an active request and that occured in a completed request. Note that the request maintains its current state as a column in the stack_wf_request table. All other request attributes are maintains in "request attribute tables".';

CREATE VIEW api_request_note AS SELECT * FROM stack_wf_request_note;
COMMENT ON VIEW api_request_note IS 'Table that stores notes associated with a specific request and user. This is a request attribute table.';

CREATE VIEW api_request_data AS SELECT * FROM stack_wf_request_data;
COMMENT ON VIEW api_request_data IS 'Table that stores highly-variable data associated with a specific request. This is a request attribute table.';

CREATE VIEW api_request_file AS SELECT * FROM stack_wf_request_file;
COMMENT ON VIEW api_request_file IS 'Table that stores files associated with a specific request and user. This is a request attribute table.';

CREATE VIEW api_request_stakeholder_lnk AS SELECT * FROM stack_wf_request_stakeholder_lnk;
COMMENT ON VIEW api_request_stakeholder_lnk IS 'Table that links a user to a request thereby promoting the user to the role of stakeholder. A stakeholder is someone with a shared interest in a request life-cycle or resolution.  It is common for a stakeholder to request notifications when something about a request changes. This is a request attribute table.';

CREATE VIEW api_activity AS SELECT * FROM stack_wf_activity;
COMMENT ON VIEW api_activity IS 'Table that represents the activities that can be performed in a specific process. Activities are things that can happen as a result of a Request entering a state or following a transition. You might notice there is no concept of a task in this design. The activity is what should be done. The stack_wf_request_action_history table represents what pending task is to be done or what task was done. This is a request attribute table.';

CREATE VIEW api_state_activity_lnk AS SELECT * FROM stack_wf_state_activity_lnk;
COMMENT ON VIEW api_state_activity_lnk IS 'Table that links activities to states in a specific process. This table allows you to specify that the system should produce a specific activity history record as a result of entering a specific state. This table is broad in its definition of when activity history records are created. Said another way, this table does not care how or why the state changed. It just knows to create an activity history record because a state was achieved.';

CREATE VIEW api_transition_activity_lnk AS SELECT * FROM stack_wf_transition_activity_lnk;
COMMENT ON VIEW api_transition_activity_lnk IS 'Table that links activities to their respective transitions in a specific process. This table allows you to specify that the system should execute a specific activity history record as a result of performing a specific transition. This table is more specific than the stack_wf_state_activity_lnk because it more narrowly defines when an activity history record is created. Said another way, the records in this table take precedence over ones in the stack_wf_state_activity_lnk table.';

CREATE VIEW api_action_transition_lnk AS SELECT * FROM stack_wf_action_transition_lnk;
COMMENT ON VIEW api_action_transition_lnk IS 'Table that links actions to transitions in the workflow process. This table defines what actions can be performed to initiate a particular transition. Note that setting a resolution is optional. If you include resolutions, you might need to specify the same action multiple times (once per resolution). These records will act as options for the user and help them automatically set the resolution based on their choice. If you link an action to a transition with conflicting resolutions, the actions resolution will win since this is the users choice.';

CREATE VIEW api_action_target_lnk AS SELECT * FROM stack_wf_action_target_lnk;
COMMENT ON VIEW api_action_target_lnk IS 'Table that links actions to their respective targets and associated groups. This tables acts as an access list to dictate who can perform what actions. If a group is the action target, then any member of the group can perform the action for it to be valid.';

CREATE VIEW api_activity_target_lnk AS SELECT * FROM stack_wf_activity_target_lnk;
COMMENT ON VIEW api_activity_target_lnk IS 'Table that links activities to their respective targets in the workflow process. This tables dictates who receives what activities. If a group is an activity target, then all members of the group receive the activity (e.g. everyone in the group gets an email).';

CREATE VIEW api_request_activity_history AS SELECT * FROM stack_wf_request_activity_history;
COMMENT ON VIEW api_request_activity_history IS 'Table that records every activity that resulted from a transition along with the target, the user/group that resulted from the target and the records is_processed status. One can query this table to see all pending activities (is_processed = false) per request';

