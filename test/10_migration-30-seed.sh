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
echo "--------create approval traditional template coming_next--------"
echo
v_provess_uu=$(psql $psql_test $TEST_PSQL_VAR_ONLY -c " select stack_wf_template_process_create_approval_traditional(true) as process_uu")
echo "v_process_uu: $v_provess_uu"
echo
echo "--------select 'process' as coming_next--------"
echo
psql $psql_test -c " select * from stack_wf_process"
echo
echo "--------select 'state' as coming_next--------"
echo
psql $psql_test -c "select * from stack_wf_state"
echo
echo "--------select 'action' as coming_next--------"
echo
psql $psql_test -c "select * from stack_wf_action"
echo
echo "--------select 'resolution' as coming_next--------"
echo
psql $psql_test -c "select * from stack_wf_resolution"
echo
echo "--------select 'target' as coming_next--------"
echo
psql $psql_test -c "select * from stack_wf_target"
echo
echo "--------select 'group' as coming_next--------"
echo
psql $psql_test -c "select * from stack_wf_group"
echo
echo "--------select 'transition' as coming_next--------"
echo
psql $psql_test -c "select * from stack_wf_transition"
echo
echo "--------select 'action transition link' as coming_next--------"
echo
psql $psql_test -c "select * from stack_wf_action_transition_lnk"

