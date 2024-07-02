# Nushell Notes

## Read with resource embedding
- http get "http://10.178.252.176:3000/api_wf_process?select=name,description,api_wf_process_type(name)"

temp - needed for above:
drop VIEW api.api_wf_process;
CREATE OR REPLACE VIEW api.api_wf_process AS
 SELECT stack_wf_process.created,
    stack_wf_process.stack_wf_process_uu as api_wf_process_uu,
    stack_wf_process.stack_wf_process_type_uu as api_wf_process_type_uu,
    stack_wf_process.search_key,
    stack_wf_process.name,
    stack_wf_process.is_template,
    stack_wf_process.is_processed,
    stack_wf_process.description
   FROM stack_wf_process

- http get "http://10.178.252.176:3000/api_wf_process?select=name,description,...api_wf_process_type(process_type:name)"
  - where "..." flattens or spreads the resource to remove the surrounding json object brackets/braces
  - where "process_type" is the alias for name
