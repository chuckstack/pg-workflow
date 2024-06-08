#!/bin/bash

set -e

################################################
# Script description:
#
# This script converts a file with SQL CREATE TABLE statements into a file with CREATE VIEW statements.
# It also preserves the table comments, changes "COMMENT ON TABLE" to "COMMENT ON VIEW",
# adds a prefix to the view name (e.g., api_), and saves the newly created file to the current directory
# of the script (not the directory of the file passed in).
#
# The script does the following:
#
# 1. It checks if an input file is provided as a command-line argument. If not, it displays the usage message and exits.
#
# 2. It sets the input file name based on the provided argument and generates the output file name by appending "_views.sql" to the input file name (without
#
# 3. It reads the input file line by line using a `while` loop.
#
# 4. For each line, it checks if the line starts with "CREATE TABLE":
#    - If it does, it extracts the table name using `awk` and stores it in a variable.
#    - It creates the view statement using the extracted table name, referring to the original table name in the FROM clause, and adds the "api_" prefix to
#    - It writes the view statement to the output file.
#
# 5. If the line starts with "COMMENT ON TABLE":
#    - It changes "COMMENT ON TABLE" to "COMMENT ON VIEW".
#    - It extracts the table name from the comment using `awk`, removes the prefix using `sed`, and adds the "api_" prefix to the view name.
#    - It writes the modified comment to the output file.
#    - It adds an empty line after the comment in the output file.
#
# 6. Finally, it displays a success message indicating that the views have been created in the output file.
################################################

# Check if the input file is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

# load the script name and path into variables and change to the current directory
TEST_SCRIPTNAME=$(readlink -f "$0")
#echo "TEST_SCRIPTNAME: $TEST_SCRIPTNAME"
TEST_SCRIPTPATH=$(dirname "$TEST_SCRIPTNAME")
#echo "TEST_SCRIPTPATH: $TEST_SCRIPTPATH"
TEST_SCRIPTBASENAME=$(basename "$0")
#echo "TEST_SCRIPTBASENAME: $TEST_SCRIPTBASENAME"
cd $TEST_SCRIPTPATH

# load the input file name and path into variables
TEST_TARGETNAME=$(readlink -f "$1")
#echo "TEST_TARGETNAME: $TEST_TARGETNAME"
TEST_TARGETPATH=$(dirname "$TEST_TARGETNAME")
#echo "TEST_TARGETPATH: $TEST_TARGETPATH"
TEST_TARGETBASENAME=$(basename "$1")
#echo "TEST_TARGETBASENAME: $TEST_TARGETBASENAME"

input_file=$1
#echo "input_file: $input_file"
script_dir=$TEST_SCRIPTPATH
#echo "script_dir: $script_dir"
output_file="$script_dir/${TEST_TARGETBASENAME%.*}_views.sql"
#echo "output_file: $output_file"

rm $output_file

# Process each line of the input file
while IFS= read -r line; do
  # Check if the line starts with "CREATE TABLE"
  if [[ $line =~ ^CREATE\ TABLE ]]; then
    # Extract the table name
    table_name=$(echo "$line" | awk '{print $3}')
    #echo "table_name: $table_name"
    view_name=$(echo "$table_name" | sed 's/stack_\(wf_\)\?/api_/')
    #echo "view_name: $view_name"

    # Create the view statement
    view_statement="CREATE VIEW $view_name AS SELECT * FROM $table_name;"

    # Write the view statement to the output file
    echo "$view_statement" >> "$output_file"
  elif [[ $line =~ ^COMMENT\ ON\ TABLE ]]; then
    # Change "COMMENT ON TABLE" to "COMMENT ON VIEW"
    line=$(echo "$line" | sed 's/COMMENT ON TABLE/COMMENT ON VIEW/')
    #echo "comment line: $line"

    # Write the modified comment to the output file
    echo "$line" | sed "s/stack_\(wf_\)\?$table_name/$view_name/" >> "$output_file"

    # Add an empty line after the comment
    echo "" >> "$output_file"
  fi
done < "$input_file"

echo "Views created successfully in $output_file"
