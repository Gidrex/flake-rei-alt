{ machineName, ... }:
{
  programs.foot.settings.main.font = "GeistMonoNerdFontMono:size=16";

  home.sessionVariables.FLAKE_MACHINE = machineName;
}
