
#todo: this need to be moved to the examples directory

#!/bin/bash
set -e

# load the script name and path into variables and change to the current directory
TEST_SCRIPTNAME=$(readlink -f "$0")
TEST_SCRIPTPATH=$(dirname "$TEST_SCRIPTNAME")
TEST_BASENAME=$(basename "$0")
cd $TEST_SCRIPTPATH

source test.properties

psql_test="$TEST_PSQL_HOST $TEST_PSQL_ERR_STOP $TEST_PSQL_USER $TEST_PSQL_DB"
echo "psql_test: $psql_test"
echo

# create a new process from the approval template
v_process_uu=$(psql $psql_test $TEST_PSQL_VAR_ONLY -c " select stack_wf_template_process_create_approval_traditional(false,'employee leave') ")
echo "v_process_uu: $v_process_uu"
echo

# pick a random user for now
v_user_uu=$(psql $psql_test $TEST_PSQL_VAR_ONLY -c " select stack_user_uu from stack_user limit 1 ")
echo "v_user_uu: $v_user_uu"
echo

v_request_uu=$(psql $psql_test $TEST_PSQL_VAR_ONLY -c " select stack_wf_request_create_from_process('$v_process_uu', '$v_user_uu') ")
echo "v_request_uu: $v_request_uu"
echo

# Add some request data
psql $psql_test -c \
"
INSERT INTO stack_wf_request_data (stack_wf_request_uu, name, value)
VALUES
    ('$v_request_uu', 'leave_type', 'Vacation'),
    ('$v_request_uu', 'start_date', '2023-07-01'),
    ('$v_request_uu', 'end_date', '2023-07-05'),
    ('$v_request_uu', 'reason', 'Taking a family vacation')
"

psql $psql_test -c \
"
INSERT INTO stack_wf_request_note (stack_wf_request_uu, stack_user_uu, note)
VALUES ('$v_request_uu', '$v_user_uu', 'Submitting leave request for approval')
"

psql $psql_test -c \
"
SELECT stack_wf_request_get_notes('$v_request_uu',4)
"

psql $psql_test -c \
"
SELECT stack_wf_request_get_data('$v_request_uu')
"

psql $psql_test -c \
"
SELECT stack_wf_request_get_actions('$v_request_uu')
"
# todo: as of when this comment is made, you need to manually insert activity history records
psql $psql_test -c \
"
SELECT stack_wf_request_get_activity_history('$v_request_uu')
"

# todo:
## function to show last x notes (done)
## function to show request data (done)
## function to show next available actions (with resolutions) (done)
## function to show activities (all and open) (done)
## function to show request summary (postponed)
##   current state,
##   current resolution,
##   request data (array)
##   open activities,
##   next actions available
##   last x notes (array)
# function to do action (next here)
# questions and thoughts:
# assumes get actions function was called to get available actions (actually )
# set state
# create activity history
