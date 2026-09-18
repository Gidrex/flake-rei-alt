# Single source of truth for user/machine constants.
# Imported once in flake.nix and passed to modules via extraSpecialArgs as `vars`.
{
  user = {
    name = "gidrex";
    displayName = "Gidrex";
    fullName = "Alexander";
    mail = "Desench@proton.me";
    homeDirectory = "/home/gidrex";
    flakeDir = "~/flake-rei";
  };

  # Reserved for future use (currently unused, kept here instead of flake.nix
  # so the public keys are not lost and stay searchable in one place).
  sshKeys = {
    # tigerlake
    rei = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkcwdevqLSxMqKZEo94A4w2VRgeSRCZm5j+hM0pafDf gidrex@rei";
    # icelake
    shou = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgmd6mBmIKY5akqKrnTkaJZjKcrCeVIsHOxZW6Xotir Desench@proton.me";
  };

  # Non-free packages allowed while `allowUnfree = false` (see nix/pkgs.nix).
  allowUnfree = [
    "unrar"
    "obsidian"
  ];

  # Per-machine foot font size. Key must match the machines/<name> directory.
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
