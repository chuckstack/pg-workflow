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
#    - It extracts the comment in quotes using `sed`.
#    - It changes "COMMENT ON TABLE" to "COMMENT ON VIEW".
#    - It adds the "api_" prefix to the view name.
#    - It rebuilds the comment line using the extracted comment and the modified view name.
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
TEST_SCRIPTPATH=$(dirname "$TEST_SCRIPTNAME")
TEST_SCRIPTBASENAME=$(basename "$0")
cd $TEST_SCRIPTPATH

# load the input file name and path into variables
TEST_TARGETNAME=$(readlink -f "$1")
TEST_TARGETPATH=$(dirname "$TEST_TARGETNAME")
TEST_TARGETBASENAME=$(basename "$1")

input_file=$1
script_dir=$TEST_SCRIPTPATH
output_file="$script_dir/${TEST_TARGETBASENAME%.*}_views.sql"

rm $output_file

# Process each line of the input file
while IFS= read -r line; do
  # Check if the line starts with "CREATE TABLE"
  if [[ $line =~ ^CREATE\ TABLE ]]; then
    # Extract the table name
    table_name=$(echo "$line" | awk '{print $3}')
    view_name=$(echo "$table_name" | sed 's/stack_\(wf_\)\?/api_/')

    # Create the view statement
    view_statement="CREATE VIEW $view_name AS SELECT * FROM $table_name;"

    # Write the view statement to the output file
    echo "$view_statement" >> "$output_file"
  elif [[ $line =~ ^COMMENT\ ON\ TABLE ]]; then
    # Extract the comment in quotes
    comment=$(echo "$line" | sed -n "s/.*'\(.*\)'.*/\1/p")

    # Change "COMMENT ON TABLE" to "COMMENT ON VIEW"
    line=$(echo "$line" | sed 's/COMMENT ON TABLE/COMMENT ON VIEW/')

    ## Add the "api_" prefix to the view name
    #view_name=$(echo "$table_name" | sed 's/stack_\(wf_\)\?/api_/')

    # Rebuild the comment line
    comment_line="COMMENT ON VIEW $view_name IS '$comment';"

    # Write the modified comment to the output file
    echo "$comment_line" >> "$output_file"

    # Add an empty line after the comment
    echo "" >> "$output_file"
  fi
done < "$input_file"

echo "Views created successfully in $output_file"
