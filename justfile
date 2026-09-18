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

# Regenerate checked-in shell completions (keeps modules free of IFD)
update-completions:
    rip completions fish > hm-modules/termTools/fish/completions_rip.fish

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
