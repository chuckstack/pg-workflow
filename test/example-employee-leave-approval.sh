
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

#echo '-------begin drop and create-------'
#echo '-------end drop and create-------'

psql $psql_test -c " select stack_wf_template_process_create_approval_traditional(false,'employee leave') "

