#!/usr/bin/env nu

# sample subcommand to list stuff
def "main list" [] {
    http get "http://10.178.252.176:3000/wf_process?select=name,description,...wf_process_type(process_type:name)"
}

# sample additional sub command
def "main insert" [] {
    print "inserting"
}

# this is my first nushell script. It includes two subcommands.
def main [] {}

