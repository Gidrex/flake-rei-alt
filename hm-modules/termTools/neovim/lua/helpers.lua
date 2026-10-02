local M = {}

function M.float_term(cmd, on_exit)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  })
  vim.fn.termopen(cmd, {
    on_exit = function(...)
      if on_exit then
        on_exit(...)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })
  vim.cmd("startinsert")
end

function M.open_lazygit()
  M.float_term("lazygit")
end

function M.open_yazi_picker()
  local tmp = vim.fn.tempname()
  local start = vim.fn.expand("%:p:h")
  if start == "" then
    start = vim.fn.getcwd()
  end
  local cmd = "yazi " .. vim.fn.shellescape(start) .. " --chooser-file=" .. vim.fn.shellescape(tmp)
  M.float_term(cmd, function()
    local f = io.open(tmp, "r")
    if f then
      local path = f:read("*l")
      f:close()
      os.remove(tmp)
      if path and path ~= "" then
        vim.schedule(function()
          vim.cmd("edit " .. vim.fn.fnameescape(path))
        end)
      end
    end
  end)
end

function M.toggle_inlay_hints()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end

return M
