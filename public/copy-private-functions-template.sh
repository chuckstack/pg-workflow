#!/bin/bash

set -e

################################################
# Script description:
#
# to be documented here...
################################################

# Check if the input file is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

# Load this script name and path into variables and change to the current directory
TEST_SCRIPTNAME=$(readlink -f "$0")
TEST_SCRIPTPATH=$(dirname "$TEST_SCRIPTNAME")
TEST_SCRIPTBASENAME=$(basename "$0")
cd $TEST_SCRIPTPATH

# Load the input file name and path into variables
TEST_TARGETNAME=$(readlink -f "$1")
TEST_TARGETPATH=$(dirname "$TEST_TARGETNAME")
TEST_TARGETBASENAME=$(basename "$1")

# describe the input and out file variables
input_file=$1
script_dir=$TEST_SCRIPTPATH
output_file="$script_dir/${TEST_TARGETBASENAME%.*}_api.sql"

# remove previous results
rm -f $output_file

# Process each line of the input file

  # Ignore indented lines and lines containing 'trigger_func' in the function name because we will not expose triggers or their functions

  # Check if the line starts with "CREATE" and contains "FUNCTION" - if so, extract details from the function

    # Extract the function name ($func_name)

    # Derive the public function name ($func_name_pub)

    # Combine the function parameters onto a single line to make it easier to process the comma delimited list of process variables and types. Note this means you will need to remove carriage returns and effectively join lines ($func_param_concat)

    # Extract the function parameter names and parameter types into an array ($func_param_array)

    # Extract the function return type ($func_return)

    # Extract the function definition body ($func_body)

    # Extract the function comment, if present ($func_comment)

    # Generate the public wrapper function to be writtent to file

    # Add an empty line after each function definition

# write output file
