# User/machine constants, passed as `vars`.
{
  user = {
    name = "gidrex";
    displayName = "Gidrex";
    fullName = "Alexander";
    mail = "Desench@proton.me";
    homeDirectory = "/home/gidrex";
  };

  github = {
    mail = "Gidrex0@proton.me";
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjmm5IkD+dmNMv/GvpTMdOI++NtltjSxhaIpmI3a7NI github@cp508";
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
