# todos

## next
- framework: finish migration-02 to pupulate the request

## ddl
- 

## templates
- update migration-03 to include link records
    - what are resulting activities
    - who(target) can execute action

## framework
- finish migration-02 to pupulate the request
- create function to list actions (and by whom)
- create function to execute action
- manage link automation (create stuff, prevent stuff, list what's next, list who can do next, etc...)

-- conventions, questions, and thoughts
-- need to copy the postgrest => user management infrastructure
-- todo: add created, updated, is_active
-- todo: developer note: need concept of a resolution
-- todo: developer note: take note of the concept of the term role - group and role seems to serve a similar purpose.
-- todo: developer note: need the concept of is_default - specifically for the default state of a request
-- todo: developer note: consider the concept of a is_template process - when a request is created, the process artifacts are cloned along with the process_uu as well. - this may not make sense...
-- todo: developer note: consider creating a chuboe_system_element table to collect a unique list of columns, their descriptions and any other attribute we wish to track per column. Consider doing the same for tables. Allow for markdown in description.
-- todo: developer note: needs index optimization
-- todo: developer note: needs cascade FK types - needs to be explicitely stated.
-- todo: developer note: chuboe_action seems to be a mix between action and task (traditional workflow term)
-- todo: developer note: everything needs an is_active to prevent deletes.
-- todo: developer note: consider adding search_key to every primary table (non-link-table) - this gives users the ability to create short codes for records without needing to spell out the full name or knowing the uuid
-- todo: translation tables

--possible improvements
-- There is no explicit concept of a "task" or "work item" that represents an assignable unit of work within a workflow.
-- The model lacks a way to define and store complex business rules or conditions that govern the workflow transitions.
-- There is no mechanism to handle parallel or concurrent activities within a workflow.
-- Workflow versioning: The ability to manage multiple versions of a workflow process and handle ongoing requests during process updates.
-- Escalation and reminders: Mechanisms to escalate overdue tasks or send reminders to users.
-- Audit trail and history: Tracking and storing the complete history of a request, including all state changes, actions, and user interactions.
-- Reporting and analytics: Provisions for generating reports and analyzing workflow metrics and performance.

