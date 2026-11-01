# Shared modules wiring; machine deltas in machines/<name>.
{
  imports = [
    ./core/nix.nix
    ./core/identity.nix
    ./core/packages.nix
    ./core/theme.nix
    ./core/xdg.nix

    ./shell/vcs.nix
    ./shell/search.nix
    ./shell/system.nix
    ./docs.nix
    ../agents/mcp.nix

    ./sound/mpv.nix

    ./termTools/claude-code
    ./termTools/crush
    ./termTools/fish
    ./termTools/helix
    ./termTools/kimi
    ./termTools/nixvim-rei.nix
    ./termTools/opencode
    ./termTools/pi
    ./termTools/yazi
    ./termTools/less.nix

    ./security/keys.nix
    ./security/sops.nix
    ./security/rclone.nix

    ./services/searxng.nix
    ./services/syncthing.nix

    ./wayland/foot.nix
    ./wayland/kitty.nix

    ./themes/qt.nix
  ];
}
