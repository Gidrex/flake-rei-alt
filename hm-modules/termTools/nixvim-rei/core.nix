{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  inherit (import ./helpers.nix { inherit pkgs; }) codelldbPath;
  cfg = config.programs.nixvim-rei;
in
{
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      # Sets EDITOR/VISUAL=nvim
      defaultEditor = true;

      # Pin source to silence the follows warning.
      nixpkgs.source = inputs.nixpkgs;

      # Lazy engine for pickers.nix triggers.
      plugins.lz-n.enable = true;

      globals = {
        mapleader = " ";
        codelldb_path = codelldbPath;
        # Unused providers: skip their startup cost.
        loaded_node_provider = 0;
        loaded_perl_provider = 0;
        loaded_python3_provider = 0;
        loaded_ruby_provider = 0;
        # matchit remaps % at startup and would clobber the select-whole-file bind.
        loaded_matchit = 1;
      };

      opts = {
        number = true;
        relativenumber = true;
        cursorline = true;
        mouse = "";
        termguicolors = true;
        wrap = true;
        linebreak = true;
        breakindent = true;
        laststatus = 3;
        shada = "!,'100,<50,s10,h";
        fixendofline = false;
        tabstop = 2;
        shiftwidth = 2;
        softtabstop = 2;
        expandtab = true;
        scrolloff = 5;
        updatetime = 250;
        timeoutlen = 300;
        guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175";
      };

      colorscheme = "catppuccin";
      colorschemes.catppuccin = {
        enable = true;
        settings = {
          flavour = "mocha";
          compile.enabled = false;
          # Foot bg shows through everywhere.
          transparent_background = true;
          float.transparent = true;
          # Inline diff (<leader>Gi) as red/green: changed lines read as added (default ChangeLn is
          # near-invisible on mocha), deleted virtual lines get a red bg instead of red text only.
          custom_highlights.__raw = ''
            function()
              return {
                GitSignsChangeLn = { link = "GitSignsAddLn" },
                GitSignsDeleteVirtLn = { link = "DiffDelete" },
              }
            end
          '';
        };
      };

      diagnostic.settings = {
        virtual_text = true;
        signs = true;
        underline = true;
        update_in_insert = false;
        severity_sort = true;
      };
    };
  };
}
