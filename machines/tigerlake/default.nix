{ machineName, ... }:
{
  programs.foot.settings.main.font = "GeistMonoNerdFontMono:size=16";
  programs.ghostty = {
    enable = true;
    settings.font-size = 17;
  };

  home.sessionVariables.FLAKE_MACHINE = machineName;
}
