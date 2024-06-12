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

# identify all functions that need to be migrated
while read -r func_name; do
  echo "Processing function: $func_name"

  # get public api function name
  func_name_pub=$(echo "$func_name" | sed -E 's/^stack_/api_/')
  echo "  - func_name_pub: $func_name_pub"

  func_param_concat=$(sed -n "/$func_name/,/)/p" $input_file | sed -n '1,/)/p' | sed '$d' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/stack_wf_request_get_notes//; s/[()]//g; s/\s+/ /g' | sed '/REPLACE/d' | sed 's/,//g' | sed 's/DEFAULT.*//')
  echo "  - func_param_concat: $func_param_concat"

  # Add your desired processing steps here
  # For example, you can execute SQL statements using the function name
  # psql -c "SELECT $func();" your_database
done < <(awk '/^CREATE.*FUNCTION/ {sub(/\($/,""); split($0, a, / +/); print a[5]}' $input_file  | awk '!/trigger|sample|stopper/')
