-- Neuro-autocomplete (minuet-ai) via blink.cmp.
-- DeepSeek V4.1 Flash on the Opencode Go endpoint (chat-protocol model;
-- newest flash family; the endpoint has no "latest" alias, family slugs
-- are the rolling names). Muse Spark is Responses-API-only: it answers
-- ModelProtocolUnsupported on /chat/completions, which is all minuet
-- 0.10.0 speaks, so it cannot be used here.
-- Key comes from sops at runtime (path in vim.g, value never in repo).
-- Opencode Go requires an `x-opencode-session` header with a stable id
-- per conversation (routing + prompt caching); it lives in stdpath('data').
local M = {}

local function opencode_session_id()
  local path = vim.fn.stdpath("data") .. "/minuet-opencode-session"
  local f = io.open(path, "r")
  local sid = f and (f:read("*l") or "") or ""
  if f then
    f:close()
  end
  sid = vim.trim(sid)
  if sid == "" then
    sid = vim.fn.sha256(os.time() .. "-" .. vim.fn.getpid() .. "-" .. math.random()):sub(1, 32)
    vim.fn.writefile({ sid }, path)
    pcall(vim.fn.setfperm, path, "rw-------")
  end
  return sid
end

-- Deferred to first InsertEnter (lz.n equivalent for extraPlugins modules).
function M.setup()
  vim.api.nvim_create_autocmd("InsertEnter", {
    once = true,
    callback = function()
      local opencode_sid = opencode_session_id()
      require("minuet").setup({
        provider = "openai_compatible",
        request_timeout = 2.5,
        throttle = 1500,
        debounce = 600,
        blink = { enable_auto_complete = false },
        curl_extra_args = { "-A", "minuet-nvim" },
        provider_options = {
          openai_compatible = {
            api_key = function()
              local path = vim.g.minuet_api_key_file or ""
              local kf = io.open(path, "r")
              if not kf then
                return ""
              end
              local key = kf:read("*l") or ""
              kf:close()
              return vim.trim(key)
            end,
            end_point = "https://opencode.ai/zen/go/v1/chat/completions",
            model = "deepseek-v4.1-flash",
            name = "Deepseek",
            transform = {
              function(data)
                data.headers["x-opencode-session"] = opencode_sid
                return data
              end,
            },
            optional = { max_tokens = 56, top_p = 0.9 },
          },
        },
      })
    end,
  })
end

-- Manual AI completion trigger (bound to <A-y> in insert mode).
function M.show()
  require("blink.cmp").show({ providers = { "minuet" } })
end

return M
