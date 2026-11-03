# Machines

- `tigerlake` - my laptop-doc station with tigerlake arch
- `icelake` - my laptop with icelake arch
 
## Nix installing on non-NixOS systems
Install nix via a script or your system's package manager and sometimes you will optionally need to:
```sh
sudo groupadd nix-users
sudo usermod -aG nix-users $(whoami) # nix-users group must be
sudo mkdir -p -m 0755 /nix/store
sudo chown -R root:nixbld /nix
sudo systemctl start nix-daemon
sudo systemctl enable --now nix-daemon.socket nix-daemon.service
```

### First system-build with home-manager
```sh
export FLAKE_MACHINE=<machine name>
git clone git@codeberg.org:Gidrex/flake-rei.git ~/flake-rei
nix run --experimental-features "flakes nix-command" home-manager/master -- switch --flake ~/flake-rei/#"$FLAKE_MACHINE" --experimental-features "nix-command flakes"
```

## Setup niri config (icelake, tigerlake):
```sh
export FLAKE_MACHINE=<machine name>
~/flake-rei/scripts/setup_niri.sh
```

If `~/.config/niri` already exists, the script moves it to a timestamped backup
(`~/.config/niri.bak.YYYYMMDD-HHMMSS`) before linking the new config.

## rclone gdrive mount
Declarative via `hm-modules/security/rclone.nix` + sops secrets (`gdrive_*`).
Mounts automatically to `~/gdrive`. Remount: `systemctl --user restart rclone-mount:@gdrive.service`.

## searxng

For add a search engine, add:
`http://localhost:8888/search?q=%s&category_general=1&language=auto&time_range=&safesearch=0&theme=simple` 
