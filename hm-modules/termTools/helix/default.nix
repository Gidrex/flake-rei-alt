{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./lsp.nix
  ];

  programs.helix = {
    enable = true;

    ignores = [
      ".build/"

      # image
      "*.png"
      "*.jpg"
      "*.jpeg"
      "*.svg"
      "*.webp"

      # doc
      "*.docx"
      "*.pdf"
    ]; # .ignore and .git/ already included

    settings = {
      theme = lib.mkDefault "catppuccin_mocha";

      editor = {
        line-number = "relative";
        bufferline = "never";
        default-line-ending = "lf";
        cursorline = true;
        auto-info = true;
        color-modes = true;
        mouse = false;
        continue-comments = false;
        completion-replace = true;
        insert-final-newline = false;
        popup-border = "popup";

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        soft-wrap = {
          enable = true;
          max-wrap = 120;
          wrap-at-text-width = false;
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        statusline = {
          left = [
            "mode"
            "spinner"
            "file-modification-indicator"
            "read-only-indicator"
          ];
          center = [
            "version-control"
            "file-name"
          ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
          ];
          separator = "│";
          mode = {
            normal = "NORMAL";
            insert = "-- INSERT --";
            select = "-- SELECT --";
          };
        };

        indent-guides = {
          render = true;
          character = "▏";
        };
      };
      keys = {
        normal = {
          S-z = lib.mkIf config.programs.lazygit.enable [
            ":new"
            ":insert-output ${pkgs.lazygit}/bin/lazygit"
            ":buffer-close!"
            ":redraw"
          ];
          # Chooser file is per-helix-PID: two instances never share a pick,
          # and quitting yazi with no pick opens nothing (test -s guard).
          C-y = lib.mkIf config.programs.yazi.enable [
            ":sh rm -f /tmp/yazi-path-$PPID"
            ":insert-output ${pkgs.yazi}/bin/yazi %{buffer_name} --chooser-file=/tmp/yazi-path-$PPID"
            ":open %sh{test -s /tmp/yazi-path-$PPID && cat /tmp/yazi-path-$PPID}"
            ":redraw"
            ":reload-all"
            ":set mouse false"
            ":set mouse true"
          ];
          A-w = ":w";
          A-q = ":q";
          space.space = ":reload-all";
          space.q = ":pipe ${pkgs.libqalculate}/bin/qalc -s 'maxdeci 2' -t -f /dev/stdin";
          space.m = ":sh foot -d error -T 'Glow Preview' glow -p -w 0 %{buffer_name} 2>/dev/null";
        };
      };
    };
  };
}
