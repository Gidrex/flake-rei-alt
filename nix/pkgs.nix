# Locked nixpkgs instantiation shared by all homeConfigurations.
# Unfree is deny-by-default; extra packages are allow-listed in nix/vars.nix.
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
