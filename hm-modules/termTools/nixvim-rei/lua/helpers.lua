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
  -- No Wayland/X11 for yazi here: ueberzugpp draws its overlay against the foot
  -- window, not this 90% float, so images land offset. Without a display yazi
  -- falls back to inline chafa (correctly positioned, terminal bg).
  local cmd = "env -u WAYLAND_DISPLAY -u DISPLAY yazi "
    .. vim.fn.shellescape(start)
    .. " --chooser-file="
    .. vim.fn.shellescape(tmp)
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

--- Prompt for a Vim regex, highlight every match and visually select the first one.
--- Single-selection approximation of "select regex matches": all matches stay
--- highlighted via @/ + hlsearch, the cursor jumps to '< and gn selects.
function M.select_regex()
  local start = vim.api.nvim_buf_get_mark(0, "<")
  local pat = vim.fn.input("regex: ")
  if pat == nil or pat == "" then
    return
  end
  vim.fn.setreg("/", pat)
  vim.o.hlsearch = true
  pcall(vim.api.nvim_win_set_cursor, 0, { start[1], math.max(start[2], 0) })
  local ok = pcall(vim.cmd, "normal! gn")
  if not ok then
    vim.notify("select-regex: no match for /" .. pat, vim.log.levels.WARN)
  end
end

return M
