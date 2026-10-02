-- Diff-aware hunk navigation: in diff mode fall back to builtin [c/]c,
-- otherwise delegate to gitsigns.
local M = {}

function M.next()
  if vim.wo.diff then
    vim.cmd.normal({ "]c", bang = true })
  else
    vim.schedule(function()
      require("gitsigns").nav_hunk("next")
    end)
  end
end

function M.prev()
  if vim.wo.diff then
    vim.cmd.normal({ "[c", bang = true })
  else
    vim.schedule(function()
      require("gitsigns").nav_hunk("prev")
    end)
  end
end

function M.first()
  if vim.wo.diff then
    vim.cmd.normal({ "gg]c", bang = true })
  else
    vim.schedule(function()
      require("gitsigns").nav_hunk("first")
    end)
  end
end

function M.last()
  if vim.wo.diff then
    vim.cmd.normal({ "G[c", bang = true })
  else
    vim.schedule(function()
      require("gitsigns").nav_hunk("last")
    end)
  end
end

return M
