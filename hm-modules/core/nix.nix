{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Uncommitted edits are the norm here (just check --impure); the warning is noise.
      warn-dirty = false;
    };
  };

  # genericLinux points NIX_PATH at ~/.nix-defexpr/channels, which a channel-less flake setup never has
  # (warns on every eval). Pin <nixpkgs> to the flake's nixpkgs instead.
  home.sessionVariables.NIX_PATH = lib.mkForce "nixpkgs=${inputs.nixpkgs}";

  # Weekly GC Tue 03:15; trims generations and dead store paths.
  nix.gc = {
    automatic = true;
    dates = "Tue 03:15";
    persistent = true;
    randomizedDelaySec = "30min";
    options = "--delete-older-than 14d";
  };
}
