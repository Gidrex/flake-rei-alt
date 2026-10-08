{ machineName, ... }:
{
  programs.foot.settings.main.font = "GeistMonoNerdFontMono:size=9";

  home.sessionVariables.FLAKE_MACHINE = machineName;
}
