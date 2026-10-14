# rip
# Handwritten flat completions in the style of fish's generated_completions:
# one `complete` line per flag, no __fish_rip_* helpers, no -n conditions.
# Do NOT overwrite with `rip completions fish` (that brings the helpers back) —
# edit this file by hand instead.
complete -c rip -l graveyard -d 'Directory where deleted files rest' -r -F
complete -c rip -s u -l unbury -d 'Restore the specified files or the last file if none are specified' -r -F
complete -c rip -s d -l decompose -d 'Permanently deletes the graveyard'
complete -c rip -s s -l seance -d 'Prints files that were deleted in the current directory'
complete -c rip -s i -l inspect -d 'Print some info about FILES before burying'
complete -c rip -s f -l force -d 'Non-interactive mode'
complete -c rip -s h -l help -d 'Print help'
complete -c rip -s V -l version -d 'Print version'
complete -c rip -f -a completions -d 'Generate shell completions file'
complete -c rip -f -a graveyard -d 'Print the graveyard path'
complete -c rip -f -a help -d 'Print this message or the help of the given subcommand(s)'
