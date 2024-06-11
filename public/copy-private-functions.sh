#!/bin/bash

# Read the SQL file
sql_file="../private/migration-20-func.sql"

# Iterate over each line in the SQL file
while IFS= read -r line; do
  # Check if the line starts with "CREATE FUNCTION" and is not indented
  if [[ $line =~ ^CREATE\ FUNCTION\ (stack_|stack_wf_)([a-zA-Z0-9_]+)\( ]]; then
    # Extract the function name and replace the prefix
    function_name="${BASH_REMATCH[2]}"
    public_function_name="api_$function_name"

    # Extract the function parameters and return type
    params_and_return=$(echo "$line" | sed -E 's/^CREATE FUNCTION (stack_|stack_wf_)[a-zA-Z0-9_]+\(//;s/\).*$//')
    return_type=$(echo "$line" | sed -E 's/^.*RETURNS //;s/ AS.*$//')

    # Read the comment for the function
    comment=""
    while IFS= read -r comment_line; do
      if [[ $comment_line =~ ^COMMENT\ ON\ FUNCTION\ (stack_|stack_wf_)[a-zA-Z0-9_]+\(.*\)\ is\ \'(.*)\'\; ]]; then
        comment="${BASH_REMATCH[2]}"
        break
      fi
    done < <(tail -n +2 <<< "$line")

    # Generate the public function code
    public_function_code=$(cat <<EOF
CREATE FUNCTION $public_function_name($params_and_return)
RETURNS $return_type AS
\$BODY\$
BEGIN
  RETURN wf_private.stack_$function_name($params_and_return);
END;
\$BODY\$
LANGUAGE plpgsql
SECURITY DEFINER;
COMMENT ON FUNCTION $public_function_name($params_and_return) is '$comment';

EOF
)

    # Output the public function code
    echo "$public_function_code"
  fi
done < "$sql_file"
