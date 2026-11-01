# Task runner for the flake-rei Home Manager configuration.

@_default:
    just --list --unsorted

# Development checks

# Format all Nix files (width 120).
fmt:
    fd -e nix -X nixfmt --width 120

# Check Nix formatting without modifying files.
fmt-check:
    fd -e nix -X nixfmt --check --width 120

# Validate niri configuration when niri is installed.
niri-check:
    #!/usr/bin/env -S bash -euo pipefail
    if command -v niri >/dev/null; then
      niri validate
    else
      echo "skip: niri not installed"
    fi

# Run all fast QA checks.
qa: fmt-check niri-check

# Dry-run Home Manager evaluation for one machine or all machines.
check machine="all":
    #!/usr/bin/env -S bash -euo pipefail
    hosts="{{ machine }}"
    if [ "$hosts" = "all" ]; then
      hosts="icelake tigerlake"
    fi
    for host in $hosts; do
      echo "==> dry-run eval: $host"
      nix build --impure ".#homeConfigurations.$host.activationPackage" --dry-run
    done

# Neovim

# Build the local nixvim configuration and check headless startup.
# Requires FLAKE_MACHINE=icelake|tigerlake. Not part of QA because it is slower.
nvim-smoke:
    #!/usr/bin/env -S bash -euo pipefail
    : "${FLAKE_MACHINE:?Set FLAKE_MACHINE=icelake|tigerlake}"
    work=$(mktemp -d)
    trap 'rm -rf "$work"' EXIT
    mkdir -p "$work/config/nvim"

    initfile=$(nix build --impure --no-link --print-out-paths ".#homeConfigurations.$FLAKE_MACHINE.config.programs.nixvim.build.initSource" | tail -1)
    ln -s "$initfile" "$work/config/nvim/init.lua"

    extrafiles=$(nix build --impure --no-link --print-out-paths ".#homeConfigurations.$FLAKE_MACHINE.config.programs.nixvim.build.extraFiles" | tail -1)
    if [ -d "$extrafiles/lua" ]; then
      ln -s "$extrafiles/lua" "$work/config/nvim/lua"
    fi

    pkg=$(nix build --impure --no-link --print-out-paths ".#homeConfigurations.$FLAKE_MACHINE.config.programs.nixvim.build.package" | tail -1)
    log="$work/smoke.log"
    rc=0
    XDG_CONFIG_HOME="$work/config" "$pkg/bin/nvim" --headless -i NONE -c 'qa!' >"$log" 2>&1 || rc=$?
    if [ "$rc" -ne 0 ] || grep -qE 'E[0-9]+:|Error' "$log"; then
      echo "nvim-smoke: FAIL"
      cat "$log"
      exit 1
    fi
    echo "nvim-smoke: OK"

# Home Manager

# Apply Home Manager (new generation, backup previous).
# Requires FLAKE_MACHINE=icelake|tigerlake; extra arguments are passed through.
hm *args:
    ./scripts/hm.sh {{ args }}

# Security

# Scan a Home Manager closure for CVEs with vulnix.
# Defaults to the live profile; accepts an explicit store path for older generations.
# The first run downloads the NVD feed. Exit 0 = clean, 2 = advisories found.
vulnix-audit profile="$HOME/.local/state/nix/profiles/home-manager":
    #!/usr/bin/env -S bash -euo pipefail
    attempts=5
    delay=20
    for ((i = 1; i <= attempts; i++)); do
      set +e
      nix run nixpkgs#vulnix -- -w ./vulnix-whitelist.toml --closure --show-description "{{ profile }}"
      rc=$?
      set -e
      if [ "$rc" -eq 0 ] || [ "$rc" -eq 2 ] || [ "$rc" -eq 3 ]; then
        exit "$rc"
      fi
      if [ "$i" -eq "$attempts" ]; then
        echo "vulnix-audit: NVD fetch still failing after $attempts attempts (rc=$rc)" >&2
        exit "$rc"
      fi
      echo "vulnix-audit: attempt $i/$attempts failed (rc=$rc), retry in ${delay}s..." >&2
      sleep "$delay"
    done

# Scan full git history and staged changes for leaked secrets.
secrets-scan:
    nix run nixpkgs#gitleaks -- detect --source . --verbose --redact
    nix run nixpkgs#gitleaks -- protect --source . --staged --verbose --redact

# Run both security scans and report a combined result.
# Exit code priority: vulnix-audit, then secrets-scan.
audit profile="$HOME/.local/state/nix/profiles/home-manager":
    #!/usr/bin/env -S bash -euo pipefail
    vulnix_rc=0
    secrets_rc=0
    just vulnix-audit "{{ profile }}" || vulnix_rc=$?
    just secrets-scan || secrets_rc=$?
    echo "==> audit summary: vulnix-audit=$vulnix_rc secrets-scan=$secrets_rc"
    if [ "$vulnix_rc" -ne 0 ]; then
      exit "$vulnix_rc"
    fi
    exit "$secrets_rc"

# Assets

# Generate blurred wallpapers in parallel, skipping up-to-date outputs.
blur-wallpapers:
    #!/usr/bin/env -S bash -euo pipefail
    if ! command -v magick >/dev/null; then
      printf '\033[0;31mmagick not found, cannot blur wallpapers\033[0m\n' >&2
      exit 1
    fi

    nproc=$(nproc 2>/dev/null || echo 4)
    jobs=$((nproc > 1 ? nproc - 1 : 1))
    for dir in assets/wallpapers/*/; do
      [ -d "$dir" ] || continue
      blur_dir="${dir}blur/"
      mkdir -p "$blur_dir"
      find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 |
        xargs -0 -r -P "$jobs" -I {} bash -c '
          img="$0"
          filename=$(basename "$img")
          blur_dir="$1"
          if [ ! -f "$blur_dir$filename" ] || [ "$img" -nt "$blur_dir$filename" ]; then
            echo "Creating blurred version of $filename"
            magick "$img" -blur 0x25 "$blur_dir$filename"
          fi
        ' {} "$blur_dir"
    done
