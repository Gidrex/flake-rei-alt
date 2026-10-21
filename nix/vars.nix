# User/machine constants, passed as `vars`.
{
  user = {
    name = "gidrex";
    displayName = "Gidrex";
    fullName = "Alexander";
    mail = "Desench@proton.me";
    homeDirectory = "/home/gidrex";
  };

  # Unfree allow-list (deny-by-default, see nix/pkgs.nix).
  allowUnfree = [
    "unrar"
    "obsidian"
    "rtk"
    "crush" # fsl11Mit; terminal agent like opencode
  ];

  # Do not bump without a home-manager migration.
  stateVersion = "26.05";

  theme = {
    flavor = "mocha";
    accent = "blue";
  };
}
