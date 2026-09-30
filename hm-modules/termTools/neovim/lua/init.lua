---@diagnostic disable: undefined-global

-- Theme: Catppuccin Mocha
require("catppuccin").setup({
  flavour = "mocha",
  compile = {
    enabled = false,
  }
})
vim.cmd.colorscheme "catppuccin"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.mouse = ""  -- disable mouse
vim.opt.termguicolors = true
vim.opt.wrap = true -- soft-wrap
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.laststatus = 3 -- global statusline
vim.opt.shada = "!,'100,<50,s10,h"
vim.opt.fixendofline = false -- do not insert final newline

-- Indent: 2 spaces everywhere (Python stays 4 via ruff/PEP8)
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

-- Do not auto-continue comments (drop c/r/o; ftplugins reset it, so re-apply)
vim.opt.formatoptions:remove({ "c", "r", "o" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

vim.opt.guicursor =
"n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

-- UI Plugins Setup
require("ibl").setup({
  indent = { char = "▏" },
  scope = { enabled = false },
})

require("render-markdown").setup({})

-- Git review: gutter signs (gitsigns) + side-by-side diff (diffview)
require("gitsigns").setup({})
require("diffview").setup({})

-- Picker: snacks.nvim (replaces telescope-nvim)
require("snacks").setup({
  picker = { enabled = true },
})

-- Diagnostics list UI
require("trouble").setup({})

require("aerial").setup({
  on_attach = function(bufnr)
    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,
})

-- Treesitter setup (updated for 1.0.0+)
local status_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
if status_ts then
  ts_configs.setup({
    highlight = { enable = true },
  })
else
  -- If configs module is missing (v1.0.0+), treesitter highlight might be managed differently
  -- or we can use the built-in vim.treesitter.start for certain cases.
  -- Most users on 1.0.0 don't need manual setup for basic highlights if grammars are present.
end

require("lualine").setup({
  options = {
    theme = "auto",
    component_separators = "│",
    section_separators = "",
    globalstatus = true,
  },
  sections = {
    lualine_a = { { "mode", fmt = function(str) return str:upper() end } },
    lualine_b = { "branch", "filetype" },
    lualine_c = { "filename" },
    lualine_x = { "diagnostics" },
    lualine_y = { "selectioncount", "progress" },
    lualine_z = { "location", "encoding" },
  },
})

require("which-key").setup({})

-- DAP: adapters come from extraPackages (Nix store), codelldb path injected from Nix.
local dap = require("dap")
local dapui = require("dapui")
dapui.setup({})
dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui"] = function() dapui.close() end

dap.adapters.python = {
  type = "executable",
  command = "python3",
  args = { "-m", "debugpy.adapter" },
}
dap.adapters.delve = {
  type = "server",
  port = "${port}",
  executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
}
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = { command = vim.g.codelldb_path, args = { "--port", "${port}" } },
}
dap.configurations.python = {
  { type = "python", request = "launch", name = "Launch file", program = "${file}" },
}
dap.configurations.go = {
  { type = "delve", request = "launch", name = "Debug file", program = "${file}" },
  { type = "delve", request = "launch", name = "Debug test", mode = "test", program = "${file}" },
}
dap.configurations.rust = {
  {
    type = "codelldb",
    request = "launch",
    name = "Launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
  },
}

-- Conventional-commit friendly: spell + 72-col wrap in gitcommit buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 72
  end,
})

-- Load LSP configuration
local status_lsp, _ = pcall(require, "lsp")
if not status_lsp then
  print("Warning: LSP configuration not found (did you 'git add' it?)")
end

-- Load Keybindings
require("keys")
