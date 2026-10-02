{ ... }:
{
  programs.nixvim = {
    extraFiles = {
      "lua/helpers.lua".source = ./lua/helpers.lua;
      "lua/hunks.lua".source = ./lua/hunks.lua;
      "lua/autocmds.lua".source = ./lua/autocmds.lua;
      "lua/format-cond.lua".source = ./lua/format-cond.lua;
      "lua/dap-setup.lua".source = ./lua/dap-setup.lua;
      "lua/minuet-setup.lua".source = ./lua/minuet-setup.lua;
      "lua/pickers.lua".source = ./lua/pickers.lua;
    };

    extraConfigLua = builtins.readFile ./lua/extra.lua;

    # Byte-compiled traces hide real line numbers.
    performance.byteCompileLua.enable = false;
  };
}
