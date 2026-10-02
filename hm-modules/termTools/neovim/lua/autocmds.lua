-- Shared autocmd callbacks (referenced from nixvim autoCmd, no logic in Nix).
local M = {}

-- Do not auto-continue comments (ftplugins reset formatoptions, so re-apply).
function M.no_comment_continue()
  vim.opt_local.formatoptions:remove({ "c", "r", "o" })
end

-- Conventional-commit friendly: spell + 72-col wrap in gitcommit buffers.
function M.gitcommit_opts()
  vim.opt_local.spell = true
  vim.opt_local.textwidth = 72
end

-- Show inlay hints when the attached server provides them.
function M.maybe_enable_inlay_hints(args)
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if client and client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
  end
end

return M
