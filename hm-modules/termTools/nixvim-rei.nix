# Neovim comes from the nixvim-rei flake input (remote URL in flake.nix).
# This single enable reproduces the full config 1:1.
# Source selection lives in the justfile, not here (a module cannot pick
# flake inputs): rebuild recipes pass `--override-input nixvim-rei <path>`
# when /home/gidrex/Projects/nixvim-rei exists, else the locked remote.
{ inputs, ... }:
{
  imports = [ inputs.nixvim-rei.homeModules.default ];

  programs.nixvim-rei.enable = true;
}
