# Declarative xdg defaults (mimeapps.list), merged into a mutable file on activation
# (our keys win, entries added by apps stay). Foot is the folder handler (foot ships no
# MimeType of its own, so kitty-open.desktop would win inode/directory by cache order).
{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  generated = config.xdg.configFile."mimeapps.list".source;
in
{
  # Don't symlink the read-only store file; merge it into the real ones instead.
  xdg.configFile."mimeapps.list".enable = false;
  xdg.dataFile."applications/mimeapps.list".enable = false;

  home.activation.mergeMimeapps = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    for f in ${config.xdg.configHome}/mimeapps.list ${config.xdg.dataHome}/applications/mimeapps.list; do
      # leftover link from the old symlinked setup
      if [[ -L $f && $(readlink "$f") == /nix/store/* ]]; then run rm "$f"; fi
      run mkdir -p "$(dirname "$f")"
      run ${pkgs.crudini}/bin/crudini --ini-options=nospace --merge "$f" < ${generated}
    done
  '';

  xdg = {
    mimeApps = {
      enable = true;

      defaultApplications = {
        "inode/directory" = mkIf config.programs.foot.enable "foot-open-folder.desktop";

        "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
        "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
        "x-scheme-handler/clash" = "clash-verge.desktop";
        "x-scheme-handler/clash-verge" = "clash-verge.desktop";
        "x-scheme-handler/discord" = "equibop.desktop";
        "x-scheme-handler/discord-1093053626198523935" = "discord-1093053626198523935.desktop";
        "x-scheme-handler/discord-990283173323739156" = "discord-990283173323739156.desktop";
        "x-scheme-handler/ror2mm" = "r2modman.desktop";
        "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
        "x-scheme-handler/clashmeta" = "flclash-url-handler.desktop";
        "x-scheme-handler/flclash" = "flclash-url-handler.desktop";
        "x-scheme-handler/antigravity" = "antigravity.desktop";
        "x-scheme-handler/http" = "userapp-Glide-RMIPQ3.desktop";
        "x-scheme-handler/https" = "userapp-Glide-RMIPQ3.desktop";
        "x-scheme-handler/chrome" = "userapp-Glide-RMIPQ3.desktop";
        "text/html" = "userapp-Glide-RMIPQ3.desktop";
        "application/x-extension-htm" = "userapp-Glide-RMIPQ3.desktop";
        "application/x-extension-html" = "userapp-Glide-RMIPQ3.desktop";
        "application/x-extension-shtml" = "userapp-Glide-RMIPQ3.desktop";
        "application/xhtml+xml" = "userapp-Glide-RMIPQ3.desktop";
        "application/x-extension-xhtml" = "userapp-Glide-RMIPQ3.desktop";
        "application/x-extension-xht" = "userapp-Glide-RMIPQ3.desktop";
        "image/png" = "feh.desktop";
        "image/jpeg" = "feh.desktop";
        "image/jpg" = "feh.desktop";
        "image/gif" = "feh.desktop";
        "image/webp" = "feh.desktop";
        "image/bmp" = "feh.desktop";
        "application/pdf" = "org.kde.okular.desktop";
      };

      associations.added = {
        "x-scheme-handler/tg" = [
          "org.telegram.desktop.desktop"
          "userapp-AyuGram Desktop-95JMU3.desktop"
        ];
        "x-scheme-handler/tonsite" = [
          "org.telegram.desktop.desktop"
          "userapp-AyuGram Desktop-JNBMU3.desktop"
        ];
        "x-scheme-handler/clash" = "clash-verge.desktop";
        "x-scheme-handler/clash-verge" = "clash-verge.desktop";
        "x-scheme-handler/http" = "userapp-Glide-RMIPQ3.desktop";
        "x-scheme-handler/https" = "userapp-Glide-RMIPQ3.desktop";
        "x-scheme-handler/chrome" = "userapp-Glide-RMIPQ3.desktop";
        "text/html" = "userapp-Glide-RMIPQ3.desktop";
        "application/x-extension-htm" = "userapp-Glide-RMIPQ3.desktop";
        "application/x-extension-html" = "userapp-Glide-RMIPQ3.desktop";
        "application/x-extension-shtml" = "userapp-Glide-RMIPQ3.desktop";
        "application/xhtml+xml" = "userapp-Glide-RMIPQ3.desktop";
        "application/x-extension-xhtml" = "userapp-Glide-RMIPQ3.desktop";
        "application/x-extension-xht" = "userapp-Glide-RMIPQ3.desktop";
      };
    };

    desktopEntries.foot-open-folder = mkIf config.programs.foot.enable {
      name = "Foot (open folder)";
      exec = "${pkgs.foot}/bin/foot --working-directory=%f";
      mimeType = [ "inode/directory" ];
      noDisplay = true;
    };
  };
}
