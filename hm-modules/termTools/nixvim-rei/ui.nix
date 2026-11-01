{ config, lib, ... }:
let
  cfg = config.programs.nixvim-rei;
in
{
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins = {
      lualine = {
        enable = true;
        settings = {
          options = {
            theme = "auto";
            component_separators = "│";
            section_separators = "";
            globalstatus = true;
          };
          sections = {
            lualine_a = [
              {
                __unkeyed-1 = "mode";
                fmt.__raw = "function(str) return str:upper() end";
              }
            ];
            lualine_b = [
              "branch"
              "filetype"
            ];
            lualine_c = [ "filename" ];
            lualine_x = [ "diagnostics" ];
            lualine_y = [
              "selectioncount"
              "progress"
            ];
            lualine_z = [
              "location"
              "encoding"
            ];
          };
        };
      };

      gitsigns.enable = true;
      # File icons for diffview/snacks/lualine/aerial (diffview warns without it).
      # Nerd font is assumed (blink nerd_font_variant = "mono").
      web-devicons.enable = true;
      which-key = {
        enable = true;
        # Auto-triggers cover only g/z single letters; m needs a manual
        # trigger or no popup shows. <auto> must stay, it is replaced not merged.
        settings.triggers = [
          {
            __unkeyed-1 = "<auto>";
            mode = "nxso";
          }
          {
            __unkeyed-1 = "m";
            mode = "nx";
          }
        ];
        # Helix-like m menu: mini.surround maps carry no desc, so label them
        # here (spec only overrides popup text, mappings stay plugin-owned).
        # mm/ma/mi already have descs via programs.nixvim.keymaps.
        settings.spec = [
          {
            __unkeyed-1 = "ms";
            desc = "Surround add";
            mode = "nx";
          }
          {
            __unkeyed-1 = "md";
            desc = "Surround delete";
          }
          {
            __unkeyed-1 = "mr";
            desc = "Surround replace";
          }
        ];
      };
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };
      indent-blankline = {
        enable = true;
        settings = {
          indent.char = "▏";
          scope.enabled = false;
        };
      };
      mini = {
        enable = true;
        modules = {
          pairs = { };
          ai = { };
          comment = {
            mappings = {
              comment = "gc";
              textobject = "gc";
            };
          };
          surround = {
            mappings = {
              add = "ms";
              delete = "md";
              replace = "mr";
              # Helix-like m menu shows exactly ms/md/mr: unused find/highlight
              # maps (mf/mF/mh/mn) stay disabled ("" = no mapping).
              find = "";
              find_left = "";
              highlight = "";
              update_n_lines = "";
            };
          };
        };
      };
    };
  };
}
