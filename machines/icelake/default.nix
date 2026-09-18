{ vars, ... }:
{
  programs.foot.settings.main.font = "GeistMonoNerdFontMono:size=${toString vars.footFontSize.icelake}";

  home.sessionVariables.FLAKE_MACHINE = "icelake";
}
