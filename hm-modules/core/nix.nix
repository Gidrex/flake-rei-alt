{ pkgs, lib, ... }:
{
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Weekly GC Tue 03:15; trims generations and dead store paths.
  nix.gc = {
    automatic = true;
    dates = "Tue 03:15";
    persistent = true;
    randomizedDelaySec = "30min";
    options = "--delete-older-than 14d";
  };
}
