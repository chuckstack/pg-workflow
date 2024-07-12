#!/usr/bin/env nu

#let config = open config.toml
#print $"config says ($config.database.IP)"

# sample subcommand to list stuff
def "list" [] {
    http get "http://10.178.252.176:3000/wf_process?select=name,description,...wf_process_type(process_type:name)"
}
alias "main list" = list

# sample additional sub command
def "insert" [] {
    print "inserting"
}
alias "main insert" = insert

# entry point for script - returns help
export def main [] {
    help main # Return useful information
}

