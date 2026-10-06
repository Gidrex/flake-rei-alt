# Shared modules wiring; machine deltas in machines/<name>.
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
    ./termTools/nixvim-rei.nix
    ./termTools/opencode
    ./termTools/yazi
    ./termTools/less.nix

    ./security/keys.nix
    ./security/sops.nix
    ./security/rclone.nix

    ./services/searxng.nix

    ./wayland/foot.nix
    ./wayland/kitty.nix

    ./themes/qt.nix
  ];
}
