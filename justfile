# Justfile for flake-rei (home-manager dotfiles flake)

# Local nixvim-rei checkout wins over the remote flake input when present.
# Rebuild recipes below pass this as `--override-input` (empty = locked remote).
# scripts/hm.sh mirrors this logic in bash (single source for `just hm` / fish `hm`).
# NOTE: nixvim-rei is a git repo, so a path input only sees committed files —
# commit there first, or the rebuild silently uses stale content.
has_local_nixvim := path_exists(env_var('HOME') + "/Projects/nixvim-rei/flake.nix")
nixvim_override := if has_local_nixvim == "true" { "--override-input nixvim-rei " + env_var('HOME') + "/Projects/nixvim-rei" } else { "" }

@_default:
    just --list --unsorted

# Format all nix files (width 120)
fmt:
    fd -e nix -X nixfmt --width 120

# Check formatting without modifying (CI/QA)
fmt-check:
    fd -e nix -X nixfmt --check --width 120

# Validate niri configs (skipped when niri is absent, e.g. non-niri hosts)
niri-check:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v niri >/dev/null; then niri validate; else echo "skip: niri not installed"; fi

# QA: formatting + niri validation
qa: fmt-check niri-check

# Dry-run eval of one machine or all (default). Makes no system changes.
check machine="all":
    #!/usr/bin/env bash
    set -euo pipefail
    hosts="{{ machine }}"
    if [ "$hosts" = "all" ]; then hosts="icelake tigerlake"; fi
    for h in $hosts; do
      echo "==> dry-run eval: $h"
      nix build --impure {{ nixvim_override }} ".#homeConfigurations.$h.activationPackage" --dry-run
    done

# Headless startup check of the nixvim config from the nixvim-rei input
# (catches Lua errors like E5113 that eval can't see). Plugins come from the
# wrapper itself, so no per-plugin assembly. Requires FLAKE_MACHINE.
# Not part of `qa` (slow). Develop the config in /home/gidrex/Projects/nixvim-rei
# (it has its own `just nvim-smoke` against a minimal smoke host).
nvim-smoke:
    #!/usr/bin/env bash
    set -euo pipefail
    : "${FLAKE_MACHINE:?Set FLAKE_MACHINE=icelake|tigerlake}"
    work=$(mktemp -d)
    trap 'rm -rf "$work"' EXIT
    mkdir -p "$work/config/nvim"
    initfile=$(nix build --impure {{ nixvim_override }} --no-link --print-out-paths ".#homeConfigurations.$FLAKE_MACHINE.config.programs.nixvim.build.initSource" | tail -1)
    ln -s "$initfile" "$work/config/nvim/init.lua"
    extrafiles=$(nix build --impure {{ nixvim_override }} --no-link --print-out-paths ".#homeConfigurations.$FLAKE_MACHINE.config.programs.nixvim.build.extraFiles" | tail -1)
    if [ -d "$extrafiles/lua" ]; then
      ln -s "$extrafiles/lua" "$work/config/nvim/lua"
    fi
    pkg=$(nix build --impure {{ nixvim_override }} --no-link --print-out-paths ".#homeConfigurations.$FLAKE_MACHINE.config.programs.nixvim.build.package" | tail -1)
    log="$work/smoke.log"
    rc=0
    XDG_CONFIG_HOME="$work/config" "$pkg/bin/nvim" --headless -i NONE -c 'qa!' > "$log" 2>&1 || rc=$?
    if [ "$rc" -ne 0 ] || grep -qE 'E[0-9]+:|Error' "$log"; then echo "nvim-smoke: FAIL"; cat "$log"; exit 1; fi
    echo "nvim-smoke: OK"

# Real home-manager switch. Requires FLAKE_MACHINE (icelake|tigerlake).
hm *args:
    ./scripts/hm.sh {{ args }}

# CVE scan of a home-manager closure (transitive runtime deps).
# Default is the live (current) profile; pass an explicit store path to audit an older generation.
# First run downloads the NVD feed (~minutes); later runs use ~/.cache/vulnix.
# Known false positives live in vulnix-whitelist.toml (name-mismatch CVEs).
# Exit 0 = clean, 2 = advisories found. NVD 503s are retried (the feed flaps).
vulnix-audit profile="$HOME/.local/state/nix/profiles/home-manager":
    #!/usr/bin/env bash
    set -uo pipefail
    attempts=5
    delay=20
    for ((i = 1; i <= attempts; i++)); do
      set +e
      nix run nixpkgs#vulnix -- -w ./vulnix-whitelist.toml --closure --show-description "{{ profile }}"
      rc=$?
      set -e
      if [ "$rc" -eq 0 ] || [ "$rc" -eq 2 ] || [ "$rc" -eq 3 ]; then exit "$rc"; fi
      if [ "$i" -eq "$attempts" ]; then
        echo "vulnix-audit: NVD fetch still failing after $attempts attempts (rc=$rc)" >&2
        exit "$rc"
      fi
      echo "vulnix-audit: attempt $i/$attempts failed (rc=$rc), retry in ${delay}s..." >&2
      sleep "$delay"
    done

# Scan the repo for leaked secrets: full history + staged changes.
# Exit 1 = findings. sops ENC[...] blobs are ciphertext, gitleaks ignores them;
# real allow-listing (if ever needed) goes to .gitleaksignore in repo root.
secrets-scan:
    #!/usr/bin/env bash
    set -euo pipefail
    nix run nixpkgs#gitleaks -- detect --source . --verbose --redact
    nix run nixpkgs#gitleaks -- protect --source . --staged --verbose --redact

# Full security audit: CVE scan of the closure + secret-leak scan of the repo.
# Both phases always run; summary at the end. Exit 0 = clean.
# Exit code priority: vulnix-audit (0 clean / 2 advisories / 1 infra fail) then secrets-scan (0/1).
audit profile="$HOME/.local/state/nix/profiles/home-manager":
    #!/usr/bin/env bash
    set -uo pipefail
    vulnix_rc=0
    sec_rc=0
    just vulnix-audit "{{ profile }}" || vulnix_rc=$?
    just secrets-scan || sec_rc=$?
    echo "==> audit summary: vulnix-audit=$vulnix_rc secrets-scan=$sec_rc"
    if [ "$vulnix_rc" -ne 0 ]; then exit "$vulnix_rc"; fi
    exit "$sec_rc"

# Generate blurred versions of wallpapers in each directory (parallel processing)
blur-wallpapers:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v magick > /dev/null || (echo -e "\\033[0;31mmagick not found, cannot blur wallpapers\\033[0m" && exit 1)
    nproc=$(nproc 2>/dev/null || echo 4)
    jobs=$((nproc > 1 ? nproc - 1 : 1))
    for dir in assets/wallpapers/*/; do
        blur_dir="${dir}blur/"
        mkdir -p "$blur_dir"
        find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | \
        xargs -0 -P "$jobs" -I {} bash -c '
            img="$0"
            filename=$(basename "$img")
            blur_dir="$1"
            # Skip if blurred version exists and is newer than source
            if [ ! -f "$blur_dir$filename" ] || [ "$img" -nt "$blur_dir$filename" ]; then
                echo "Creating blurred version of $filename"
                magick "$img" -blur 0x25 "$blur_dir$filename"
            fi
        ' {} "$blur_dir"
    done
