# Full Neovim configuration lives beside this wrapper in nixvim-rei/.
{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./nixvim-rei
  ];

  programs.nixvim-rei.enable = true;
}
