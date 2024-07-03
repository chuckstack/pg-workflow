# @describe sample script to list workflows

# @cmd
list-process() {
	curl "http://10.178.252.176:3000/api_wf_process?select=name,description,api_wf_process_type(name)"
}

eval "$(argc --argc-eval "$0" "$@")"
