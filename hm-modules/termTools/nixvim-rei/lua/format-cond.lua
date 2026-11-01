-- Conform conditions: biome.json wins (matches `biome check --write`),
-- deno_fmt only for pure-deno projects without biome config.
-- Mutually exclusive, so no stop_after_first needed.
local M = {}

local function has_file(ctx, names)
  return vim.fs.find(names, { path = vim.fs.dirname(ctx.filename), upward = true })[1] ~= nil
end

local function in_biome_project(ctx)
  return has_file(ctx, { "biome.json", "biome.jsonc" })
end

local function in_deno_project(ctx)
  return has_file(ctx, { "deno.json", "deno.jsonc" })
end

function M.is_biome(_, ctx)
  return in_biome_project(ctx)
end

function M.is_deno(_, ctx)
  return not in_biome_project(ctx) and in_deno_project(ctx)
end

return M
