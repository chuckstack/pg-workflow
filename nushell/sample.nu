#!/usr/bin/env nu

#let config = open config.toml
#print $"config says ($config.database.IP)"

# sample subcommand to list stuff
export def "list" [] {
    let config = init 
    #print $"config says IP:port is: ($config.database.IP):($config.database.port)"
    http get $"http://($config.database.IP):($config.database.port)/wf_process?select=name,description,...wf_process_type\(process_type:name)"
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

