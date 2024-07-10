#!/usr/bin/env nu

# ref: 20240704-nushell-create-crud.txt
# not tested - simply created by ai - delete when no longer valuable

# A CLI tool for interacting with a REST service
def main [
    --base-url (-b): string # Base URL of the REST service
] {
    print "REST API CLI Tool"
    print $"Base URL: ($base_url)"
}

# Perform a GET request on the specified table
def "main get" [
    --table (-t): string  # Name of the table to query
    --where (-w): string  # Optional WHERE clause for filtering
    --columns (-c): string  # Optional columns to retrieve
] {
    let url = $"($env.base_url)/($table)"
    let params = []
    if $where != null { $params = ($params | append $"where=($where)") }
    if $columns != null { $params = ($params | append $"columns=($columns)") }
    let query = ($params | str join '&')
    let full_url = if ($query | is-empty) { $url } else { $"($url)?($query)" }
    print $"GET request to: ($full_url)"
    # Implement the actual HTTP GET request here
}

# Perform a POST request to create a new record in the specified table
def "main post" [
    --table (-t): string  # Name of the table to insert into
    --data (-d): string  # JSON string containing the data to insert
] {
    let url = $"($env.base_url)/($table)"
    print $"POST request to: ($url)"
    print $"Data: ($data)"
    # Implement the actual HTTP POST request here
}

# Perform a PUT request to update a record in the specified table
def "main put" [
    --table (-t): string  # Name of the table to update
    --id (-i): string  # ID of the record to update
    --data (-d): string  # JSON string containing the data to update
] {
    let url = $"($env.base_url)/($table)/($id)"
    print $"PUT request to: ($url)"
    print $"Data: ($data)"
    # Implement the actual HTTP PUT request here
}

# Perform a DELETE request to remove a record from the specified table
def "main delete" [
    --table (-t): string  # Name of the table to delete from
    --id (-i): string  # ID of the record to delete
] {
    let url = $"($env.base_url)/($table)/($id)"
    print $"DELETE request to: ($url)"
    # Implement the actual HTTP DELETE request here
}

# Perform a PATCH request to partially update a record in the specified table
def "main patch" [
    --table (-t): string  # Name of the table to update
    --id (-i): string  # ID of the record to update
    --data (-d): string  # JSON string containing the data to update
] {
    let url = $"($env.base_url)/($table)/($id)"
    print $"PATCH request to: ($url)"
    print $"Data: ($data)"
    # Implement the actual HTTP PATCH request here
}
