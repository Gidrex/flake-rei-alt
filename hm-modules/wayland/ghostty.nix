# Ghostty mirrors foot.nix; enabled per machine (tigerlake), font size set there.
{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  programs.ghostty.settings = {
    command = mkIf config.programs.fish.enable "${pkgs.fish}/bin/fish";
    font-family = "GeistMono Nerd Font Mono";
    window-padding-x = 0;
    window-padding-y = 0;
    window-decoration = "none";
    cursor-style = "bar";
    cursor-style-blink = false;
    mouse-hide-while-typing = true;
    confirm-close-surface = false;
    keybind = [ "ctrl+enter=unbind" ]; # default toggle_fullscreen; let ctrl+enter reach apps
  };

  # niri's env carries TERM=foot from home.sessionVariables and fish re-sources it; restore ghostty's own.
  programs.fish.interactiveShellInit = mkIf config.programs.ghostty.enable ''
    set -q GHOSTTY_RESOURCES_DIR; and set -gx TERM xterm-ghostty
  '';
}
