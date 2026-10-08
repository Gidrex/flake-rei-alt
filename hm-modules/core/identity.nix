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

    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
      "${config.home.homeDirectory}/.nix-profile/bin"
      "${config.home.homeDirectory}/.kimi-code/bin"
      "/usr/bin"

      # Package managers
      "${config.home.homeDirectory}/.volta/bin"
      "${config.home.homeDirectory}/.cargo/bin"
      "${config.home.homeDirectory}/.npm-global/bin"
      "${config.home.homeDirectory}/.deno/bin"
      "${config.home.homeDirectory}/go/bin"

      # Flutter dev
      "/opt/flutter/bin"
      "/opt/android-sdk/tools/bin"
      "${config.home.homeDirectory}/Android/Sdk/cmdline-tools/latest/bin"
      "${config.home.homeDirectory}/Android/Sdk/platform-tools"
      "${config.home.homeDirectory}/Android/Sdk/emulator"
    ];
  };

  fonts.fontconfig.enable = true;

  # Disable on an actual NixOS host.
  targets.genericLinux.enable = true;

  news.display = "silent";
}
