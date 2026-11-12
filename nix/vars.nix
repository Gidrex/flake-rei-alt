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
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjmm5IkD+dmNMv/GvpTMdOI++NtltjSxhaIpmI3a7NI github@gidrex";
  };

  # Unfree allow-list (deny-by-default, see nix/pkgs.nix).
  allowUnfree = [
    "unrar"
    "obsidian"
    "rtk"
    "crush" # fsl11Mit; terminal agent like opencode
  ];

  # systemd sandbox for network-facing user daemons (merge into `Service`).
  # No PrivateTmp/ProtectHome here: per-service, they can break shared /tmp locks or home writes.
  serviceHardening = {
    NoNewPrivileges = true;
    ProtectSystem = "strict";
    PrivateDevices = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    ProtectHostname = true;
    ProtectProc = "invisible";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = "@system-service";
    RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
    CapabilityBoundingSet = "";
    UMask = "0077";
  };

  # Do not bump without a home-manager migration.
  stateVersion = "26.05";
}
