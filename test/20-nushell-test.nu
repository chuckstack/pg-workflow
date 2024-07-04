#!/usr/bin/env nu

# testing using Nushell script

## Read with resource embedding
http get "http://10.178.252.176:3000/api_wf_process?select=name,description,api_wf_process_type(name)"

## Read with "spreading" or flattening the process_type name at the same level
http get "http://10.178.252.176:3000/api_wf_process?select=name,description,...api_wf_process_type(process_type:name)"
#  - where "..." flattens or spreads the resource to remove the surrounding json object brackets/braces
#  - where "process_type" is the alias for name

## return using in json format
http get "http://10.178.252.176:3000/api_wf_process?select=name,description,...api_wf_process_type(process_type:name)" | to json
