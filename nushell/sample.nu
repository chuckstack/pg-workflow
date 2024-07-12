#!/usr/bin/env nu

#let config = open config.toml
#print $"config says ($config.database.IP)"

# sample subcommand to list stuff
export def "list" [
    --table_name (-t): string       # Example: wf_process
    --column_names (-c): string     # Example: name,description,...wf_process_type(process_type:name)
] {
    if $table_name == null {
        error make {msg: "table_name is required"}
    }
    mut x_col_name = ""
    if $column_names != null {
        $x_col_name = $"?select=($column_names)"
    } else {
        $x_col_name = "?select=name,description,...wf_process_type\(process_type:name)"
    }
    print $"Column_Names: ($x_col_name)"
    let config = init 
    #print $"config says IP:port is: ($config.database.IP):($config.database.port)"
    http get $"http://($config.database.IP):($config.database.port)/($table_name)($x_col_name)"
    #http get $"http://($config.database.IP):($config.database.port)/($table_name)?select=name,description,...wf_process_type\(process_type:name)"
}
alias "main list" = list

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

    # Note: the following allows for debugging
    #let config = open config.toml
    #print $"config says IP: ($config.database.IP):($config.database.port)"
    #$config
}

