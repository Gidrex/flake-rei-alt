# Single wiring point for all shared home-manager modules.
# Machine deltas live in machines/<name>/default.nix and are appended in flake.nix.
{
  imports = [
    ./core/nix.nix
    ./core/identity.nix
    ./core/packages.nix
    ./core/theme.nix

    ./shell/vcs.nix
    ./shell/search.nix
    ./shell/system.nix
    ./docs.nix

    ./sound/mpv.nix

    ./termTools/fish
    ./termTools/helix
    ./termTools/neovim
    ./termTools/opencode
    ./termTools/yazi
    ./termTools/less.nix

    ./security/keys.nix
    ./security/sops.nix
    ./security/rclone.nix

    ./wayland/foot.nix
    ./wayland/kitty.nix

    ./themes/qt.nix
  ];
}
