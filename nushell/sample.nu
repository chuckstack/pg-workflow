#!/usr/bin/env nu

# sample subcommand to list stuff
export def "list" [
    --table_name (-t): string       # Example: wf_process
    --column_names (-c): string     # Example: name,description,...wf_process_type(process_type:name)
] {
    # prepare-it
    let config = init 
    
    if $table_name == null {
        error make {msg: "table_name is required"}
    }

    mut x_col_name = ""

    # try getting preferred columns from config
    try {
        $x_col_name = $config.columns."wf_process" # TODO: needs to pull from $table_name
    } 
    print $"DEBUG x_col_name1: ($x_col_name)"

    if $column_names != null {
        $x_col_name = $"?select=($column_names)" # pull from flag
    } else if $x_col_name != "" {
        $x_col_name = $"?select=($x_col_name)" # pull from property file
    } else {
        $x_col_name = "?select=name" # default case
    }
    #print $"DEBUG x_col_name2: ($x_col_name)"

    # do-it
    #print $"DEBUG config says IP:port is: ($config.database.IP):($config.database.port)"
    http get $"http://($config.database.IP):($config.database.port)/($table_name)($x_col_name)"
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
}

