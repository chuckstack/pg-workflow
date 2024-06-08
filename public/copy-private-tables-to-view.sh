#!/bin/bash

set -e

################################################
# 1. It checks if an input file is provided as a command-line argument. If not, it displays the usage message and exits.
#
# 2. It sets the input file name based on the provided argument and generates the output file name by appending "_views.sql" to the input file name (without the extension).
#
# 3. It reads the input file line by line using a `while` loop.
#
# 4. For each line, it checks if the line starts with "CREATE TABLE":
#    - If it does, it extracts the table name using `awk` and removes the "stack_" or "stack_wf_" prefix using `sed`.
#    - It creates the view statement using the extracted table name.
#    - It writes the view statement to the output file.
#
# 5. If the line starts with "COMMENT ON TABLE":
#    - It extracts the table name from the comment using `awk` and removes the prefix using `sed`.
#    - It replaces the table name in the comment with the view name using `sed`.
#    - It writes the modified comment to the output file.
#
# 6. Finally, it displays a success message indicating that the views have been created in the output file.
#
# To use the script, save it to a file (e.g., `create_views.sh`), make it executable with `chmod +x create_views.sh`, and then run it with the input file as an argument:
#
# ```bash
# ./copy-private-tables-to-view.sh input.sql
# ```
#
# The script will generate an output file with the CREATE VIEW statements and comments based on the input file.
################################################

# Check if the input file is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

input_file=$1
output_file="${input_file%.*}_views.sql"

# Process each line of the input file
while IFS= read -r line; do
  # Check if the line starts with "CREATE TABLE"
  if [[ $line =~ ^CREATE\ TABLE ]]; then
    # Extract the table name and remove the prefix
    table_name=$(echo "$line" | awk '{print $3}' | sed 's/stack_\(wf_\)\?//')

    # Create the view statement
    view_statement="CREATE VIEW $table_name AS SELECT * FROM $table_name;"

    # Write the view statement to the output file
    echo "$view_statement" >> "$output_file"
  elif [[ $line =~ ^COMMENT\ ON\ TABLE ]]; then
    # Extract the table name from the comment and remove the prefix
    table_name=$(echo "$line" | awk '{print $4}' | sed 's/stack_\(wf_\)\?//')

    # Replace the table name in the comment with the view name
    comment=$(echo "$line" | sed "s/stack_\(wf_\)\?$table_name/$table_name/")

    # Write the comment to the output file
    echo "$comment" >> "$output_file"
  fi
done < "$input_file"

echo "Views created successfully in $output_file"

