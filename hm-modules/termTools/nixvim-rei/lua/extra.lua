-- Entry point for nixvim extraConfigLua (see default.nix): every block
-- below lives in its own module, so default.nix only references this file.
-- Diff filler: blank instead of stock "-------" (see :h fill-diff).
-- opt[k] = v would replace the whole option, so append a single entry.
vim.opt.fillchars:append({ diff = " " })
require("dap-setup")
