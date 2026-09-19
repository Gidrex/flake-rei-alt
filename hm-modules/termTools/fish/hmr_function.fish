set -l prev (home-manager generations | grep -A1 '(current)' | tail -n 1 | awk '{print $NF}')

if test -z "$prev" -o "$prev" = "(current)"
    echo "hmr: no previous generation to roll back to" >&2
    exit 1
end

echo "rolling back to $prev"
$prev/activate $argv
