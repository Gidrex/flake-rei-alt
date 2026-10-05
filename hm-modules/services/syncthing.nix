# Syncthing P2P sync for ~/Notes across icelake + tigerlake (+ phone via app).
#
# How it works:
# - The module is shared: the same config evaluates on both machines.
# - Each machine shares ~/Notes only with *peers* (itself excluded via FLAKE_MACHINE).
# - Device IDs are public (shown as QR in the GUI), so they live here in plaintext, not in sops.
#
# First-run workflow (IDs don't exist until syncthing runs once):
# 1. Apply with empty IDs below: `FLAKE_MACHINE=<this-machine> just hm`
# 2. Open http://127.0.0.1:8384 on each machine -> Actions -> Show ID (QR + string).
# 3. Paste the two IDs into `deviceIds` below, re-apply on both machines.
# 4. Phone: install Syncthing-Fork (Android), add one laptop via QR, accept the
#    "Notes" folder share, point it at the phone-side Notes directory.
#
# Ports needed on the host firewall (HM can't open them, do it once per machine):
#   sudo ufw allow 22000/tcp comment syncthing-sync
#   sudo ufw allow 22000/udp comment syncthing-sync
#   sudo ufw allow 21027/udp comment syncthing-discovery
# GUI (8384) stays on localhost, no firewall rule needed.
{ config, lib, ... }:
let
  # Fill after the first run (step 3 above). Empty string = unknown, filtered out,
  # so the first `just hm` stays a safe vanilla install and eval stays green.
  deviceIds = {
    icelake = "";
    tigerlake = "";
    # Phone (Syncthing-Fork on Android). Optional: add its ID here to make the
    # phone declarative too; until then it pairs via GUI and persists because
    # overrideDevices/overrideFolders are false.
    # phone = "";
  };

  knownIds = lib.filterAttrs (_: id: id != "") deviceIds;
  thisMachine = config.home.sessionVariables.FLAKE_MACHINE or "";
  # Peers for this host: every known device except itself.
  peerNames = builtins.attrNames (builtins.removeAttrs knownIds [ thisMachine ]);
in
{
  services.syncthing = {
    enable = true;

    # Don't recreate the default ~/Sync folder on fresh installs.
    extraOptions = [ "--no-default-folder" ];

    # False so GUI-paired devices (e.g. the phone before its ID lands here)
    # survive a `just hm`. Flip both to true once every device is declarative
    # and you want the GUI to stop drifting.
    overrideDevices = false;
    overrideFolders = false;

    settings = {
      options.urAccepted = -1; # -1 = decline anonymous usage reporting, 0 = ask later

      devices = lib.mapAttrs (name: id: { inherit id; }) knownIds;

      folders = lib.optionalAttrs (peerNames != [ ]) {
        "~/Notes" = {
          id = "notes";
          label = "Notes";
          type = "sendreceive";
          devices = peerNames;
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
      };
    };
  };
}
