# opencode
# Handwritten flat completions in the style of fish's generated_completions:
# one `complete` line per flag, no helpers, no -n conditions.
# Do NOT replace with `opencode completion fish | source` — upstream emits a
# bash-only yargs script (complete -F), which is a syntax error in fish.
# Edit this file by hand instead.
complete -c opencode -f -a completion -d 'Generate shell completion script'
complete -c opencode -f -a acp -d 'Start ACP server'
complete -c opencode -f -a mcp -d 'Manage MCP servers'
complete -c opencode -f -a attach -d 'Attach to a running opencode server'
complete -c opencode -f -a run -d 'Run opencode with a message'
complete -c opencode -f -a debug -d 'Debugging and troubleshooting tools'
complete -c opencode -f -a providers -d 'Manage AI providers and credentials'
complete -c opencode -f -a auth -d 'Manage AI providers and credentials'
complete -c opencode -f -a agent -d 'Manage agents'
complete -c opencode -f -a upgrade -d 'Upgrade opencode'
complete -c opencode -f -a uninstall -d 'Uninstall opencode'
complete -c opencode -f -a serve -d 'Start a headless opencode server'
complete -c opencode -f -a web -d 'Start opencode server and open web interface'
complete -c opencode -f -a models -d 'List all available models'
complete -c opencode -f -a stats -d 'Show token usage and cost statistics'
complete -c opencode -f -a export -d 'Export session data as JSON'
complete -c opencode -f -a import -d 'Import session data from file or URL'
complete -c opencode -f -a github -d 'Manage GitHub agent'
complete -c opencode -f -a pr -d 'Checkout a GitHub PR branch, then run opencode'
complete -c opencode -f -a session -d 'Manage sessions'
complete -c opencode -f -a plugin -d 'Install plugin and update config'
complete -c opencode -f -a db -d 'Database tools'
complete -c opencode -f -s h -l help -d 'Show help'
complete -c opencode -f -s v -l version -d 'Show version number'
complete -c opencode -f -l print-logs -d 'Print logs to stderr'
complete -c opencode -l log-level -d 'Log level' -r -a 'DEBUG INFO WARN ERROR'
complete -c opencode -f -l pure -d 'Run without external plugins'
complete -c opencode -l port -d 'Port to listen on' -r
complete -c opencode -l hostname -d 'Hostname to listen on' -r
complete -c opencode -f -l mdns -d 'Enable mDNS service discovery'
complete -c opencode -l mdns-domain -d 'Custom domain name for mDNS' -r
complete -c opencode -l cors -d 'Additional domains to allow for CORS' -r
complete -c opencode -s m -l model -d 'Model to use as provider/model' -r
complete -c opencode -f -s c -l continue -d 'Continue the last session'
complete -c opencode -s s -l session -d 'Session id to continue' -r
complete -c opencode -f -l fork -d 'Fork the session when continuing'
complete -c opencode -l prompt -d 'Prompt to use' -r
complete -c opencode -l agent -d 'Agent to use' -r
complete -c opencode -f -l auto -d 'Auto-approve permissions (dangerous)'
complete -c opencode -f -l mini -d 'Start the minimal interactive interface'
complete -c opencode -f -l no-replay -d 'Disable mini session history replay'
complete -c opencode -l replay-limit -d 'Cap visible mini replay to newest N messages' -r
