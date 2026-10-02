# Justfile for flake-rei (home-manager dotfiles flake)

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
      nix build --impure ".#homeConfigurations.$h.activationPackage" --dry-run
    done

# Real home-manager switch. Requires FLAKE_MACHINE (icelake|tigerlake).
hm:
    #!/usr/bin/env bash
    set -euo pipefail
    : "${FLAKE_MACHINE:?Set FLAKE_MACHINE=icelake|tigerlake}"
    home-manager switch --flake ./#"$FLAKE_MACHINE" -b backup

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

# Regenerate checked-in shell completions (keeps modules free of IFD)
update-completions:
    rip completions fish > hm-modules/termTools/fish/completions_rip.fish

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
    command -v magick > /dev/null || (echo -e "\\033[0;31mNo found magick\\033[0m" && exit 0)
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
