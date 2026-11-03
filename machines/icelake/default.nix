{ machineName, ... }:
{
  programs.foot.settings.main.font = "GeistMonoNerdFontMono:size=10";

  home.sessionVariables.FLAKE_MACHINE = machineName;
}
