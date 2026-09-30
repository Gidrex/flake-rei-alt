vim.g.mapleader = " "
local wk = require("which-key")

-- A-w save, A-q quit; both are free chords, Vim defaults untouched.
vim.keymap.set("n", "<A-w>", ":w<CR>", { silent = true, desc = "Save" })
vim.keymap.set("n", "<A-q>", ":q<CR>", { silent = true, desc = "Quit" })

-- Z opens LazyGit; factory ZZ/ZQ are disabled.
vim.keymap.set("n", "ZZ", "<nop>")
vim.keymap.set("n", "ZQ", "<nop>")

-- Floating terminal helper (lazygit / yazi picker)
local function float_term(cmd, on_exit)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded'
  })

  vim.fn.termopen(cmd, {
    on_exit = function(...)
      if on_exit then
        on_exit(...)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  })
  vim.cmd('startinsert')
end

local function open_lazygit()
  float_term('lazygit')
end

vim.keymap.set("n", "Z", open_lazygit, { silent = true, desc = "LazyGit" })

-- Yazi file picker (yazi with a chooser file).
-- Bound to <leader>y: <C-y> stays a Vim default (scroll up).
local function open_yazi_picker()
  local tmp = vim.fn.tempname()
  local start = vim.fn.expand('%:p:h')
  if start == '' then
    start = vim.fn.getcwd()
  end
  local cmd = 'yazi ' .. vim.fn.shellescape(start) .. ' --chooser-file=' .. vim.fn.shellescape(tmp)
  float_term(cmd, function()
    local f = io.open(tmp, 'r')
    if f then
      local path = f:read('*l')
      f:close()
      os.remove(tmp)
      if path and path ~= '' then
        vim.schedule(function()
          vim.cmd('edit ' .. vim.fn.fnameescape(path))
        end)
      end
    end
  end)
end

-- Minuet: manual AI completion trigger (auto runs via blink source).
-- make_blink_map() returns a blink-keymap list, not a vim.keymap rhs, so call show() directly.
vim.keymap.set('i', '<A-y>', function()
  require('blink.cmp').show({ providers = { 'minuet' } })
end, { desc = 'Minuet: complete manually' })

-- Hunk navigation (diff mode falls back to builtin [c/]c)
vim.keymap.set("n", "]c", function()
  if vim.wo.diff then
    vim.cmd.normal({ "]c", bang = true })
  else
    vim.schedule(function() require("gitsigns").nav_hunk("next") end)
  end
end, { desc = "Next hunk" })
vim.keymap.set("n", "[c", function()
  if vim.wo.diff then
    vim.cmd.normal({ "[c", bang = true })
  else
    vim.schedule(function() require("gitsigns").nav_hunk("prev") end)
  end
end, { desc = "Prev hunk" })

-- DAP controls: F-keys step, <leader>B group manages breakpoints/session
vim.keymap.set("n", "<F5>", function() require("dap").continue() end, { desc = "DAP: continue" })
vim.keymap.set("n", "<F10>", function() require("dap").step_over() end, { desc = "DAP: step over" })
vim.keymap.set("n", "<F11>", function() require("dap").step_into() end, { desc = "DAP: step into" })
vim.keymap.set("n", "<F12>", function() require("dap").step_out() end, { desc = "DAP: step out" })

-- Space menu, flat: single-letter leader binds, two groups (Git review, Debug).
-- LSP actions live here directly (no <leader>l subgroup):
-- c code action, r rename, D definition, h hover, F format, i inlay toggle.
wk.add({
  { "<leader>f",        function() Snacks.picker.files() end,        desc = "File Picker" },
  { "<leader>b",        function() Snacks.picker.buffers() end,      desc = "Buffers" },
  { "<leader>g",        function() Snacks.picker.git_status() end,   desc = "Git Status (Diff)" },
  { "<leader>/",        function() Snacks.picker.grep() end,         desc = "Live Grep" },
  { "<leader>d",        function() Snacks.picker.diagnostics() end,  desc = "Diagnostics" },
  { "<leader>x",        "<cmd>Trouble diagnostics toggle<CR>",       desc = "Diagnostics List (Trouble)" },
  { "<leader>y",        open_yazi_picker,                 desc = "Yazi Picker" },
  { "<leader>q",        ":!qalc -s 'maxdeci 2' -t -f /dev/stdin<CR>", desc = "Calculator" },
  { "<leader>a",        "<cmd>AerialToggle!<CR>",         desc = "Outline (Aerial)" },
  { "<leader><leader>", ":e!<CR>",                        desc = "Reload Buffer" },
  { "<leader>c",        vim.lsp.buf.code_action,          desc = "Code Action" },
  { "<leader>r",        vim.lsp.buf.rename,               desc = "Rename" },
  { "<leader>D",        vim.lsp.buf.definition,           desc = "Go to Definition" },
  { "<leader>h",        vim.lsp.buf.hover,                desc = "Hover" },
  { "<leader>F",        function() require("conform").format({ async = true, lsp_format = "fallback" }) end, desc = "Format Buffer" },
  { "<leader>i",        function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, desc = "Toggle Inlay Hints" },
  { "<leader>G",        group = "Git review" },
  { "<leader>Gs",       "<cmd>Gitsigns stage_hunk<CR>",   desc = "Stage Hunk" },
  { "<leader>Gr",       "<cmd>Gitsigns reset_hunk<CR>",   desc = "Reset Hunk" },
  { "<leader>Gp",       "<cmd>Gitsigns preview_hunk<CR>", desc = "Preview Hunk" },
  { "<leader>Gb",       "<cmd>Gitsigns blame_line<CR>",   desc = "Blame Line" },
  { "<leader>Gd",       "<cmd>Gitsigns diffthis<CR>",     desc = "Diff This" },
  { "<leader>GD",       "<cmd>DiffviewOpen<CR>",          desc = "Side-by-side Diff" },
  { "<leader>Gl",       "<cmd>DiffviewFileHistory<CR>",   desc = "File History" },
  { "<leader>B",        group = "Debug (DAP)" },
  { "<leader>Bb",       function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
  { "<leader>Bc",       function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional Breakpoint" },
  { "<leader>Br",       function() require("dap").repl.toggle() end,       desc = "REPL" },
  { "<leader>Bu",       function() require("dapui").toggle() end,          desc = "UI" },
  { "<leader>Bt",       function() require("dap").terminate() end,         desc = "Terminate" },
})

-- Surround/comment hotkeys (explicit exception to "don't touch defaults"):
-- surround ms/mr/md, comment gc.
require('mini.pairs').setup({})
require('mini.ai').setup({})
require('mini.comment').setup({
  mappings = { textobject = 'gc', comment = 'gc' }
})
require('mini.surround').setup({
  mappings = {
    add = 'ms',
    delete = 'md',
    replace = 'mr',
  }
})
