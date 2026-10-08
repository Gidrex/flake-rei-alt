{ pkgs, machineName, ... }:
{
  programs.foot.settings.main.font = "GeistMonoNerdFontMono:size=16";

  home.packages = with pkgs; [ scanmem ];

  home.sessionVariables.FLAKE_MACHINE = machineName;
}
