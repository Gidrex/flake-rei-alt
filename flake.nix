{
  description = "Gidrex flake configuration for working machines.";

  inputs = {
    # Tracks nixos-unstable. Update deliberately with `nix flake update nixpkgs`
    # (it rebuilds the world on next `just hm` — never bump blindly).
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Core
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Theming
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Helix master (build from source on each switch once input is updated).
    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

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

      # Shared by all machines; the machine delta is appended per host below.
      # New shared modules are wired in hm-modules/default.nix, not here.
      commonModules = [
        ./hm-modules
        inputs.sops-nix.homeManagerModules.sops
        inputs.catppuccin.homeModules.catppuccin
      ];

      # Explicit host map: adding a machine means adding one line here
      # plus machines/<name>/default.nix (see .agents/skills/add-machine/).
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
          # Explicit injection (replaces the old `_module.args` magic):
          # every module may take `vars`, `inputs` and `yazi-plugins`.
          extraSpecialArgs = { inherit inputs vars yazi-plugins; };
        }
      );
    };
}
