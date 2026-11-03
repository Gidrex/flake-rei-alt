# User/machine constants, passed as `vars`.
{
  user = {
    name = "gidrex";
    displayName = "Gidrex";
    fullName = "Alexander";
    mail = "Desench@proton.me";
    homeDirectory = "/home/gidrex";
    # Public half of sops `private_ssh` (default identity: Codeberg, GitLab, everything but github).
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkcwdevqLSxMqKZEo94A4w2VRgeSRCZm5j+hM0pafDf gidrex@rei";
  };

  github = {
    mail = "Gidrex0@proton.me";
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjmm5IkD+dmNMv/GvpTMdOI++NtltjSxhaIpmI3a7NI github@gidrex";
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
}
