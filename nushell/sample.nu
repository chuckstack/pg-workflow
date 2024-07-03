#!/usr/bin/env nu

# myscript.nu
def "main list" [] {
    http get "http://10.178.252.176:3000/api_wf_process?select=name,description,...api_wf_process_type(process_type:name)"
}

def "main insert" [] {
    print "inserting"
}

# important for the command to be exposed to the outside
def main [] {}

