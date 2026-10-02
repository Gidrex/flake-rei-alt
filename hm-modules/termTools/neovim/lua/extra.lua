-- Entry point for nixvim extraConfigLua (see default.nix): every block
-- below lives in its own module, so default.nix only references this file.
require("dap-setup")
require("minuet-setup").setup()
