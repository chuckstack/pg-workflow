# pg_workflow

## Challenge
Workflow is notoriously difficult. The concepts can be difficult to learn. The applications are often difficult to install and maintain, and they are either too complicated or overly simple. It is incredibly difficult to create a workflow architecture that is both generic enough and easy enough for broad adoption. Here is my attempt based on my 25 years of experience!!

## Purpose
The purpose of this project is to make pragmatic open source workflow management available to anyone who wants to use postgresql.

## Workflow Use Cases to be Supported
1. Traditional workflow involving processes, actions, states, transitions, activities, requests and resolutions. This is the use case when you think of a business process management (BPM) diagram.
1. Ad hoc workflow offering the greatest freedom and flexibility in terms of the request life cycle. Ad hoc workflows are used when institutional knowledge of approval process are well understood. Said another way, users know what roles need to be consulted for what approvals. The system simply needs to make it easy to create and process the requests.
1. Queue-based activities that enable users or groups to see and navigate to records/documents that enter a specific state. If everyone in an organization were to know when they are needed, and if everyone acted accordingly in a timely manner, the world would be a better and more efficient place.
1. Checklists for simply tracking what needs to happen and letting everyone know when stuff is done.

## Learn More
If you would like to discuss this framework, please join the [ERP Academy](https://erp-academy.chuckboecking.com/?page_id=6). [Here are the frequently asked questions -  FAQ](https://erp-academy.chuckboecking.com/?page_id=32). [Here is that others have to say about me](https://erp-academy.chuckboecking.com/?page_id=2696).

## Traditional Workflow Concepts

### Level 0 explanation: basic concepts
- Workflow Process (process for short): represents the design of a desired workflow. Let's use an employee leave approval workflow as an example. The process is the starting point for creating your workflow attributes like: what are the states, who is involved, what actions impact state changes...
- Workflow Request (request for short): represents an instance a particular workflow process. Let's use an employee leave approval for "Jane Smith on Oct 5th through Oct 29th" as an example. The workflow process will potentially spawn many, many workflow requests.

### Level 1 explanation: workflow types (background concepts needed before we create our first workflow process)
- There are a number of records that need to exist before you start creating your first workflow process.
- We will call these records: workflow 'types'.
- Luckily for you, this project creates most of the types you need during installation.
- Workflow types are important because they help developers write code against workflow concepts - not individual workflow processes. Said another way, they help developers write as little code as is possible to be used as broadly across as many workflow scenarios as is possible. 
- Workflow rypes are important because you can create actual names/values inside your process that have more meaningful context. For example: a state type = 'started' can be renamed to a state = 'drafted' in the context of document approval.
- Workflow types are important because you can have multiple names/values for the same type. For example: a state type = 'started' can exist as multiple states = 'drafted' and 'peer review' where both states logically represent the 'started' state type.
- Types act as a menu to help you create your workflow processes.
- Here are the types:
    - Process Type - indicates the type of process: traditional, ad-hoc, queue-based, checklist
    - State Type - types of states that might be included in a workflow process. Indicates if a state is a default starting point. Indicates if a state represents a completed or answered state. Indicates if a state should be locked down to prevent further processing. Example state types include: started, normal, submitted, and completed.
    - Action Type - types of actions that can be invoked to move between states. Example action types include: prepare, complete, approve, void and restart.
    - Activity Type - types of activities that can result from an action or a transition. Example activity types include: add note, send email and add stakeholder.
    - Target Type - types of people or systems that need to consulted without actually identifying them by name. Examples of target types include: requestor, stakeholder, group member and process admin.
    - Resolution Type - types of resulting request results. It is important to separate state from resolution. The problems with combining state and resolution are 1. that your list of states becomes long and duplicated, and 2. transition logic becomes overly complicated. Examples of resolution types include: approved, success, denied and cancelled.

### Level 2 explanation: workflow process creation
- Creating a complete workflow process that is ready for request execution can be either easy or difficult depending on your process complexity.
- Creating the actual new process record is as easy as choosing a search key, name, description and a process type.
- Use your workflow types as a menu to pick process options.
- You need at least two states (one as a default starting point and one as a final state).
- Chose one or more actions if you need them. If you do not chose an action, users will be able to manipulate the process state directly.
- Chose one or more resolutions.
- Create transitions between states to direct how a process flows from its default state to one of its final states. If you do not create transitions, users will be able to chose any future state from any previous state in your process.
- Create one or more groups if you need them. Examples of groups might include: Employees, Managers, HR, Executives and Purchasing.
- Create one or more targets if you need them. Note that you can target a group or a user in additional the above mentioned target types.
- todo: discuss link table population for process creation (ex: group_member_lnk)

### Level 3 explanation: workflow request creation and life cycle
- todo: here

## Architecture
- private schema holds the internal data structure
- api schema holds the public interface (both sql and rest)
- rest interface provided by postgrest
- webui interface provide by htmx through postgrest

## Installation
- to be explained later
- currently implementing the private schema

## Other notes
- supports both people and system responsibilities
- supports real-time interaction with outside systems (webhooks)
- 1,000,000% the goal to have ai help write the application
- 1,000,000% the goal to have ai help users create and manage processes and requests. 
- example ai interactions: 
    - list active requests (alt: what's next)
    - list critical requests (alt: what is going to get me fired)
    - create a new approval workflow process (alt: I need to hold people accountable)
    - create a new leave request for next week (alt: I need a vacation)
- discuss the difference between groups and roles
- discuss the relationship between targets and groups

## todo:
- see migration.todo
- add the ability to target an individual user and role (as well as a group)
- refactor table names to include chuboe_wf to designate that they belong to a specific app (do not change chuboe_user or chuboe_role)
- refresh work-instruction-admin.txt
- refresh example => employee-leave
