# Identity, env/path, host flags. EDITOR etc. unguarded (always enabled).
{ config, vars, ... }:
{
  home = {
    username = vars.user.name;
    homeDirectory = vars.user.homeDirectory;
    stateVersion = vars.stateVersion;
    enableNixpkgsReleaseCheck = false;

    sessionVariables = {
      SHELL = "fish";
      TERM = "foot";

      ANDROID_HOME = "${config.home.homeDirectory}/Android/Sdk";
      ANDROID_AVD_HOME = "${config.home.homeDirectory}/.android/avd";

      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;

      XDG_CONFIG_HOME = config.xdg.configHome;
      XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/screenshots";
    };

    # Keep only existing dirs: a missing PATH entry silently shadows commands
    # and stays broken until a rebuild happens after the tool is installed.
    sessionPath =
      let
        inherit (config.home) homeDirectory;
        filterExisting = builtins.filter (p: builtins.pathExists p);
      in
      filterExisting [
        "${homeDirectory}/.local/bin"
        "${homeDirectory}/.nix-profile/bin"
        "${homeDirectory}/.kimi-code/bin"
        # FVM default SDK before /usr/bin: bare dart/flutter must come from
        # the pinned SDK, not distro /usr/bin/dart.
        "${homeDirectory}/fvm/default/bin"
        "/usr/bin"

        # Package managers
        "${homeDirectory}/.volta/bin"
        "${homeDirectory}/.cargo/bin"
        "${homeDirectory}/.npm-global/bin"
        "${homeDirectory}/.deno/bin"
        "${homeDirectory}/go/bin"

        # Flutter dev
        "/opt/flutter/bin"
        "/opt/android-sdk/tools/bin"
        "${homeDirectory}/Android/Sdk/cmdline-tools/latest/bin"
        "${homeDirectory}/Android/Sdk/platform-tools"
        "${homeDirectory}/Android/Sdk/emulator"
      ];
  };

  fonts.fontconfig.enable = true;

  # Disable on an actual NixOS host.
  targets.genericLinux.enable = true;

  news.display = "silent";
}
