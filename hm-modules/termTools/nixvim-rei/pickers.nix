{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (import ./helpers.nix { inherit pkgs; }) snacksKey diffviewQuit;
  cfg = config.programs.nixvim-rei;
in
{
  config = lib.mkIf cfg.enable {
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
          # <leader>f searches from cwd, <leader>F from the current buffer's dir.
          (snacksKey "<leader>f" "function() require('pickers').files() end" "File Picker")
          (snacksKey "<leader>F" "function() require('pickers').files_here() end" "Files Here")
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
      # ft.csv intentionally omitted: forcing "," renders ";" files
      # (e.g. stoppingPoints__kat.csv) as a single column. Without it
      # csvview sniffs the delimiter from fallbacks.
      csvview = {
        enable = true;
        settings.parser.delimiter = {
          ft = {
            tsv = "\t";
          };
          fallbacks = [
            ","
            "\t"
            ";"
            "|"
            ":"
            " "
          ];
        };
      };
    };
  };
}
