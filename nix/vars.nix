# User/machine constants, passed as `vars`.
{
  user = {
    name = "gidrex";
    displayName = "Gidrex";
    fullName = "Alexander";
    mail = "Desench@proton.me";
    homeDirectory = "/home/gidrex";
    flakeDir = "~/flake-rei";
  };

  # Reserved, unused. Keeps public keys searchable in one place.
  sshKeys = {
    # tigerlake
    rei = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkcwdevqLSxMqKZEo94A4w2VRgeSRCZm5j+hM0pafDf gidrex@rei";
    # icelake
    shou = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgmd6mBmIKY5akqKrnTkaJZjKcrCeVIsHOxZW6Xotir Desench@proton.me";
  };

  # Unfree allow-list (deny-by-default, see nix/pkgs.nix).
  allowUnfree = [
    "unrar"
    "obsidian"
  ];

  # Foot font size per machine; key = machines/<name>.
  footFontSize = {
    icelake = 9;
    tigerlake = 14;
  };

  # Do not bump without a home-manager migration.
  stateVersion = "26.05";

  theme = {
    flavor = "mocha";
    accent = "blue";
  };
}
