{ pkgs, lib, ... }:
{
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Weekly user-profile GC (Tuesday 03:15, catches up after suspend).
  # Home-manager only trims its own generations; dead store paths go via --delete-older-than.
  nix.gc = {
    automatic = true;
    dates = "Tue 03:15";
    persistent = true;
    randomizedDelaySec = "30min";
    options = "--delete-older-than 14d";
  };
}
