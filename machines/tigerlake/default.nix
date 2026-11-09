{
  machineName,
  pkgs,
  inputs,
  ...
}:
{
  programs.foot.settings.main.font = "GeistMonoNerdFontMono:size=16";

  home.sessionVariables.FLAKE_MACHINE = machineName;

  # livediff has no config file; theme only via flag, so wrap the binary.
  home.packages = [
    (pkgs.writeShellScriptBin "livediff" ''
      exec ${inputs.livediff.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/livediff --theme catppuccin "$@"
    '')
  ];
}
