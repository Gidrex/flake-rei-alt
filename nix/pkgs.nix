# Locked nixpkgs for all machines; unfree deny-by-default (allow-list in nix/vars.nix).
{
  nixpkgs,
  system,
  vars,
}:
import nixpkgs {
  localSystem = system;
  config = {
    allowUnfree = false;
    allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) vars.allowUnfree;
  };
}
