# Nushell Notes

## Sample Nu script

Here is what is important:
- acts as both bash script and nu module
- when in nushell, issue the following to bring the file as a module into scope
  - use greetings
- make file executable using: chmod +x
- References:
  - Command Help output as structured data (includes bash scripting details)
    - https://discord.com/channels/601130461678272522/1259580889218678975/1259580889218678975

greetings.nu
```nu
#!/usr/bin/env nu
# Module description goes here...
# creating world peace

# creating world peace
export def main [] { 
    help main # prefer to use: help greeting
}

# informal salutations
export def hi [name: string] { 
    $"Hello ($name)" 
}
alias "main hi" = hi # must be defined after the namesake command definition
```

## Read with resource embedding
- http get "http://10.178.252.176:3000/wf_process?select=name,description,...wf_process_type(process_type:name)"
  - where "..." flattens or spreads the resource to remove the surrounding json object brackets/braces
  - where "process_type" is the alias for name
