{ pkgs, ... }:
let
  inherit (import ./helpers.nix { inherit pkgs; }) snacksKey diffviewQuit;
in
{
  programs.nixvim.plugins = {
    diffview = {
      enable = true;
      settings.keymaps = {
        view = [ diffviewQuit ];
        file_panel = [ diffviewQuit ];
        file_history_panel = [ diffviewQuit ];
      };
      lazyLoad.settings.cmd = [
        "DiffviewOpen"
        "DiffviewFileHistory"
      ];
    };
    trouble = {
      enable = true;
      lazyLoad.settings.cmd = "Trouble";
    };
    aerial = {
      enable = true;
      lazyLoad.settings.keys = [
        (snacksKey "<leader>a" "function() require('aerial').toggle() end" "Outline (Aerial)")
      ];
    };
    snacks = {
      enable = true;
      settings.picker = {
        enabled = true;
        # Pickers never dim the current buffer behind them
        layout.backdrop = false;
      };
      lazyLoad.settings.keys = [
        # Files opens with input focused.
        (snacksKey "<leader>f"
          "function() Snacks.picker.files({ exclude = { '*.png', '*.jpg', '*.jpeg', '*.webp', '*.gif', '*.bmp', '*.ico', '*.svg', '*.avif', '*.tif', '*.tiff', '*.heic', '*.pdf', '*.doc', '*.docx', '*.xls', '*.xlsx', '*.ppt', '*.pptx', '*.odt', '*.zip', '*.tar', '*.gz', '*.bz2', '*.xz', '*.7z', '*.rar', '*.zst', '*.mp3', '*.wav', '*.ogg', '*.flac', '*.m4a', '*.mp4', '*.mkv', '*.webm', '*.avi', '*.mov', '*.ttf', '*.otf', '*.woff', '*.woff2', '*.exe', '*.msi', '*.dmg', '*.iso', '*.db', '*.sqlite', '*.sqlite3', '*.pyc', '*.class', '*.o', '*.so', '*.dll' } }) end"
          "File Picker"
        )
        (snacksKey "<leader>b" "function() Snacks.picker.buffers() end" "Buffers")
        (snacksKey "<leader>g" "function() Snacks.picker.git_status() end" "Git Status (Diff)")
        (snacksKey "<leader>/" "function() Snacks.picker.grep() end" "Live Grep")
        (snacksKey "<leader>d" "function() Snacks.picker.diagnostics() end" "Diagnostics")
      ];
    };
    render-markdown = {
      enable = true;
      settings = {
        heading.width = "block";
        # Mirrors the icon indent; bump if icons change
        heading.right_pad = 1;
        # Rendered cursor line; raw only in insert mode
        anti_conceal.enabled = false;
      };
      lazyLoad.settings.ft = "markdown";
    };
    # Eager: tiny, enabled per buffer in autocmd.nix.
    csvview = {
      enable = true;
    };
  };
}
