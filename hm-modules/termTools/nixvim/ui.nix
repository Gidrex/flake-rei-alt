{ ... }:
{
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
    which-key.enable = true;
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
          };
        };
      };
    };
  };
}
