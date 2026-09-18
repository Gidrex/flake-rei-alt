{ pkgs, vars, ... }:
{
  programs.foot.settings.main.font = "GeistMonoNerdFontMono:size=${toString vars.footFontSize.tigerlake}";

  home.packages = with pkgs; [ scanmem ];

  home.sessionVariables.FLAKE_MACHINE = "tigerlake";
}
