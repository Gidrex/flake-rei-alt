# Neovim comes from the standalone nixvim-rei flake (input in flake.nix).
# This single enable reproduces the full config 1:1.
# Develop it in /home/gidrex/Projects/nixvim-rei, not here.
{ inputs, ... }:
{
  imports = [ inputs.nixvim-rei.homeModules.default ];

  programs.nixvim-rei.enable = true;
}
