{ pkgs, ... }:

let
  # Selected files -> clipboard as text/uri-list (paste files with Ctrl+V). `%%` is yazi's escaped `%`.
  # shortcut: only % space # ? are percent-encoded and newlines in names break it; enough for real filenames.
  copy-uri-list = ''for f in %s; do printf 'file://%%s\r\n' "$f"; done | sed 's/%%/%%25/g; s/ /%%20/g; s/#/%%23/g; s/?/%%3F/g' | ${pkgs.wl-clipboard}/bin/wl-copy -t text/uri-list'';

  # Bind func
  mkBind = on: run: desc: { inherit on run desc; };

  # Create relative motion keybindings
  relative-motions = map (num: {
    on = toString num;
    run = "plugin relative-motions ${toString num}";
    desc = "Move ${toString num} steps";
  }) (pkgs.lib.range 1 9);

  # Create tab switching keybindings
  tab-switching = map (num: {
    on = [ "<C-${toString num}>" ];
    run = "tab_switch ${toString (num - 1)}";
    desc = "Switch to tab ${toString num}";
  }) (pkgs.lib.range 1 9);

in
{
  programs.yazi.keymap.mgr.prepend_keymap = [
    # g t is yazi native Trash VFS (plugin trash); keep it free. Gdrive lives on g r.
    (mkBind [ "g" "r" ] "cd ~/gdrive/" "Go to rclone gdrive mount")

    # File operations
    # `drag` = blobdrop that follows niri workspaces (hm-modules/core/drag.sh).
    (mkBind [ "e" "d" ] "shell --orphan -- drag %s" "Drag & Drop selected files")
    (mkBind [ "e" "g" ] "shell --block -- glow -t %s" "Open file with glow")

    # Native Trash VFS: g t opens the bin, O (open --interactive) restores/empties.
    # boydaihungst/restore.yazi is deprecated upstream and broken with trash-cli 0.26
    # (trash-restore rejects home-trash absolute Paths), so u just opens the bin.
    (mkBind [ "u" ] "plugin trash" "Open trash bin (restore with O)")
    (mkBind [ "c" "m" ] "plugin chmod" "Chmod on selected files")
    (mkBind [ "c" "u" ] "shell -- ${copy-uri-list}" "Copy selected files to clipboard (paste as files)")
    # O stays free for `open --interactive` (trash restore UI); custom opener lives on e o.
    (mkBind [ "e" "o" ] "plugin open-with-cmd block" "Open with command in the terminal")
    (mkBind [ "t" "c" ] "close" "Close current tab")
    (mkBind [ "<C-t>" ] "plugin close-and-restore-tab restore" "Restore closed tab")

    # UI controls
    (mkBind [ "T" "t" ] "plugin toggle-pane min-preview" "Hide or show preview")
    (mkBind [ "T" "T" ] "plugin toggle-pane max-preview" "Maximize or restore the preview pane")

    # DuckDB operations
    (mkBind [ "g" "o" ] "plugin duckdb -open" "Open with duckdb")
    (mkBind [ "g" "u" ] "plugin duckdb -ui" "Open with duckdb ui")
    (mkBind "H" "plugin duckdb -1" "Scroll one column to the left")
    (mkBind "L" "plugin duckdb +1" "Scroll one column to the right")
  ]
  ++ relative-motions
  ++ tab-switching;
}
