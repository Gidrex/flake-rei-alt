{
  description = "Gidrex flake configuration for working machines.";

  inputs = {
    # nixos-unstable. Bump via `nix flake update nixpkgs`, never blindly.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Core
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Theming
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # NixVim (Neovim as Nix modules, tracks nixpkgs).
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # Yazi plugins
    open-with-cmd.url = "github:Ape/open-with-cmd.yazi";
    open-with-cmd.flake = false;
    close-and-restore-tab.url = "github:MasouShizuka/close-and-restore-tab.yazi";
    close-and-restore-tab.flake = false;
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      vars = import ./nix/vars.nix;
      pkgs = import ./nix/pkgs.nix { inherit nixpkgs system vars; };
      yazi-plugins = import ./nix/yazi-plugins.nix {
        inherit (nixpkgs) lib;
        inherit inputs;
      };

      # Shared modules; machine delta appended per host. New modules go in hm-modules/default.nix.
      commonModules = [
        ./hm-modules
        inputs.sops-nix.homeManagerModules.sops
        inputs.catppuccin.homeModules.catppuccin
      ];

      # New machine: one line here + machines/<name>/default.nix.
      machines = {
        icelake = ./machines/icelake;
        tigerlake = ./machines/tigerlake;
      };
    in
    {
      homeConfigurations = nixpkgs.lib.genAttrs (builtins.attrNames machines) (
        name:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = commonModules ++ [ machines.${name} ];
          # Modules may take `vars`, `inputs`, `yazi-plugins`, `machineName`.
          extraSpecialArgs = {
            inherit inputs vars yazi-plugins;
            machineName = name;
          };
        }
      );
    };
}
