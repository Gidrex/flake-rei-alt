-- Conform conditions: Deno projects (deno.json*) format with deno,
-- everything else with biome. Mutually exclusive, so no stop_after_first needed.
local M = {}

local function in_deno_project(ctx)
  return vim.fs.find({ "deno.json", "deno.jsonc" }, { path = vim.fs.dirname(ctx.filename), upward = true })[1] ~= nil
end

function M.is_deno(_, ctx)
  return in_deno_project(ctx)
end

function M.is_not_deno(_, ctx)
  return not in_deno_project(ctx)
end

function M.format_buffer()
  require("conform").format({ async = true, lsp_format = "fallback" })
end

return M
