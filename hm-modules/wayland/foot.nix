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
  programs.foot = {
    enable = true;

    settings = {
      main = {
        shell = mkIf config.programs.fish.enable "${pkgs.fish}/bin/fish";
        pad = "0x0";
        dpi-aware = "yes";
      };
      cursor = {
        style = "beam";
        blink = "no";
      };
      scrollback.lines = 10000;
      mouse.hide-when-typing = "yes";
    };
  };
}
