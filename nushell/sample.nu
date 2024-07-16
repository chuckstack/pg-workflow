#!/usr/bin/env nu

# list records from table
export def "list" [
    --table_name (-t): string       # Example: wf_process
    --column_names (-c): string     # Example: "name,description,...wf_process_type(process_type:name)"
] {
    # prepare-it
    let config = init 
    
    if ($table_name | is-empty) {
        error make {msg: "table_name is required"}
    }

    # variable to hold resulting column names
    mut result_column_names = ""

    $result_column_names = ($config.columns | get -i $table_name)
    #print $"DEBUG result_column_names1: ($result_column_names)"

    if ($column_names | is-not-empty) {
        #print "DEBUG case: column_names not empty"
        $result_column_names = $"?select=($column_names)" # pull from flag
    } else if ($result_column_names | is-not-empty) {
        #print $"DEBUG case: result_column_names not empty"
        $result_column_names = $"?select=($result_column_names)" # pull from property file
    } else {
        #print "DEBUG case: default"
        $result_column_names = "?select=name" # default case
    }
    #print $"DEBUG result_column_names2: ($result_column_names)"

    # do-it
    #print $"DEBUG config says IP:port is: ($config.database.IP):($config.database.port)"
    http get $"http://($config.database.IP):($config.database.port)/($table_name)($result_column_names)"

}
alias "main list" = list
# sample execution/test
# ./sample.nu list -t wf_activity                       # default
# ./sample.nu list -t wf_process                        # found in file
# ./sample.nu list -t wf_process -c name,description    # found in file but overridden
# ./sample.nu list -t wf_action                         # found in file - description only

# sample additional sub command
export def "insert" [] {
    print "inserting"
}
alias "main insert" = insert

# entry point for script - returns help on inself
export def main [] {
    help main
}

def init [] {
    open config.toml # returned from command
}

