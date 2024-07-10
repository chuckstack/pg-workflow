# @describe sample script to list workflows
# execute with: ./sample.sh list-process

# @cmd
list-process() {
	curl "http://10.178.252.176:3000/wf_process?select=name,description,...wf_process_type(process_type:name)"
}

eval "$(argc --argc-eval "$0" "$@")"
