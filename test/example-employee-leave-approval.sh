#!/bin/bash
set -e

# load the script name and path into variables and change to the current directory
TEST_SCRIPTNAME=$(readlink -f "$0")
TEST_SCRIPTPATH=$(dirname "$TEST_SCRIPTNAME")
TEST_BASENAME=$(basename "$0")
cd $TEST_SCRIPTPATH

source test.properties

psql_test="$TEST_HOST $TEST_PSQL_ERR_STOP $TEST_USER $TEST_DB $TEST_PSQL_SEARCH_PATH"
echo "$psql_test"

#echo '-------begin drop and create-------'
#echo '-------end drop and create-------'

psql $psql_test -c "
select stack_wf_template_process_create_approval_traditional(false,'employee leave')
"

#set search_path = 'private';
#select * from stack_wf_process;
#select * from stack_wf_state;
#select * from stack_wf_action;
#select * from stack_wf_resolution;
#select * from stack_wf_target;
#select * from stack_wf_group;
#select * from stack_wf_transition;
#select * from stack_wf_action_transition_lnk;


#TEST_HOST="-h 10.178.252.246"
#TEST_USER="-U adempiere"
#TEST_DB="-d db_20240527_01"
#TEST_DB_ADMIN="-d idempiere"
#TEST_PSQL_VAR_ONLY="-AXqt"
#TEST_PSQL_FILE="-f"
#TEST_PSQL_COMMAND="-c"
#TEST_PSQL_ERR_STOP="-v ON_ERROR_STOP=on"
#TEST_PSQL_SEARCH_PATH="-v search_path='private'"
#
##example
##psql $TEST_HOST $TEST_PSQL_ERR_STOP $TEST_USER $TEST_DB
