{
  pkgs,
  lib,
  config,
  yazi-plugins,
  ...
}:
let
  # Plugin helpers
  mkPreviewer =
    run: pattern:
    let
      isMime = lib.hasInfix "/" pattern && !lib.hasSuffix "/" pattern;
    in
    {
      inherit run;
    }
    // lib.optionalAttrs isMime { mime = pattern; }
    // lib.optionalAttrs (!isMime) { url = pattern; };

  mkPreloader = run: pattern: (mkPreviewer run pattern) // { multi = false; };

in
{
  imports = [ ./keymaps.nix ];

  programs.yazi = {
    enable = true;
    shellWrapperName = "y";

    # Plugins init
    plugins = {
      inherit (pkgs.yaziPlugins)
        chmod
        # full-border
        toggle-pane
        piper
        relative-motions
        mediainfo
        duckdb
        ;
      inherit (yazi-plugins) open-with-cmd close-and-restore-tab;
    };

    settings = {
      concurrency = 2;
      preview = {
        enabled = true;
        image_preloader = false;
        image_delay = 0;
      };
      mgr.ratio = [
        1
        2
        5
      ];
      plugin.prepend_preloaders = [
        (mkPreloader "duckdb" "*.{csv,tsv,json,parquet,txt,xlsx}")
        (mkPreloader "mediainfo" "{audio/*,video/*,image/*,application/subrip,application/postscript}")
      ];

      plugin.prepend_previewers = [
        (mkPreviewer "duckdb" "*.{csv,tsv,json,parquet,txt,xlsx,db,duckdb}")
        (mkPreviewer "mediainfo" "{audio/*,video/*,image/*,application/subrip,application/postscript}")
        {
          url = "*/";
          run = ''piper -- ${pkgs.eza}/bin/eza --tree --level=2 --color=always --icons=always --group-directories-first --no-quotes "$1"'';
        }
        {
          url = "*.md";
          run = ''
            piper -- CLICOLOR_FORCE=1 ${pkgs.glow}/bin/glow -w=$w -s=dark "$1"
          '';
        }
      ];
      tasks.image_alloc = 268435456; # 256 MB, enough for previews
    };

    initLua = ''
      require("relative-motions"):setup({
        show_numbers = "relative_absolute",
        show_motion = true
      })

      require("duckdb"):setup({
        mode = "summarized",
        cache_size = 1000,
        row_id = "dynamic",
        minmax_column_width = 21,
        column_fit_factor = 10.0
      })

      -- require("full-border"):setup { type = ui.Border.ROUNDED }
      require("close-and-restore-tab"):setup()
    '';
  };

}
# Doc
# https://github.com/wylie102/duckdb.yazi
