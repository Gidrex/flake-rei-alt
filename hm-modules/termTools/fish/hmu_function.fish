# Update flake inputs (all, or only those in $argv), commit flake.lock, switch.
set -l flake $HOME/flake-rei

if not git -C $flake symbolic-ref -q HEAD >/dev/null
    echo "hmu: detached HEAD, run 'git switch main' first" >&2
    return 1
end
# Don't mix a half-done manual lock edit into the auto commit.
if not git -C $flake diff --quiet HEAD -- flake.lock
    echo "hmu: flake.lock already has uncommitted changes" >&2
    return 1
end

nix flake update --flake $flake $argv; or return

if git -C $flake diff --quiet -- flake.lock
    echo "hmu: inputs already up to date"
    return 0
end

# Commit only flake.lock; other staged/dirty files stay untouched.
# Must commit before switching: nix reads the committed revision.
git -C $flake commit -q -m update -- flake.lock; or return
git -C $flake --no-pager log -1 --oneline

if not hm
    echo "hmu: switch failed; to drop the lock bump:" >&2
    echo "  git -C $flake reset --soft HEAD~1; and git -C $flake restore -SW flake.lock" >&2
    return 1
end
