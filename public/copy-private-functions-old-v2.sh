#!/bin/bash

set -e

################################################
# Script description:
#
# This script creates a public facing SQL schema by generating wrapper functions for the private functions.
# It reads the private functions from the input file, extracts the necessary details, and generates the corresponding public functions.
# The public functions act as a facade, allowing controlled access to the private functions.
# The script ignores indented lines, functions with 'trigger_func' in the name, and trigger definitions.
# It also preserves the comments on the functions and adds an empty line between function definitions.
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
while IFS= read -r line; do
  # Ignore indented lines and lines containing 'trigger_func' in the function name
  if [[ $line =~ ^[[:space:]] || $line =~ trigger_func ]]; then
    continue
  fi

  # Check if the line starts with "CREATE" and contains "FUNCTION"
  if [[ $line =~ ^CREATE.*FUNCTION ]]; then
    # Extract the function name
    function_name=$(echo "$line" | sed -E 's/CREATE( OR REPLACE)? FUNCTION ([a-zA-Z0-9_]+)\(.*/\2/')

    # Derive the public function name
    public_function_name=$(echo "$function_name" | sed -E 's/^stack_/api_/')

    # Combine the function parameters onto a single line
    parameters=$(sed -n "/^CREATE.*FUNCTION $function_name/,/\).*RETURNS/ {/^CREATE.*FUNCTION/d; /\).*RETURNS/d; p}" "$input_file" | tr -d '\n' | sed -E 's/[[:space:]]+//g')

    # Extract the function parameter names and types into an array
    IFS=',' read -ra param_array <<< "$parameters"

    # Extract the function return type
    return_type=$(echo "$line" | sed -E 's/.*RETURNS ([^ ]+).*/\1/')

    # Extract the function definition body
    function_body=$(sed -n "/^CREATE.*FUNCTION $function_name/,/^\$\$.*LANGUAGE plpgsql.*;/p" "$input_file")

    # Extract the function comment, if present
    comment=$(sed -n "/COMMENT ON FUNCTION $function_name/p" "$input_file")

    # Generate the public wrapper function
    echo "CREATE FUNCTION $public_function_name(${param_array[@]})" >> "$output_file"
    echo "RETURNS $return_type AS" >> "$output_file"
    echo "\$BODY\$" >> "$output_file"
    echo "BEGIN" >> "$output_file"
    echo "  RETURN wf_private.$function_name(${param_array[@]%:*});" >> "$output_file"
    echo "END;" >> "$output_file"
    echo "\$BODY\$" >> "$output_file"
    echo "LANGUAGE plpgsql" >> "$output_file"
    echo "SECURITY DEFINER;" >> "$output_file"
    if [[ -n $comment ]]; then
      echo "$comment" | sed "s/$function_name/$public_function_name/" >> "$output_file"
    fi
    echo "" >> "$output_file"
  fi
done < "$input_file"
