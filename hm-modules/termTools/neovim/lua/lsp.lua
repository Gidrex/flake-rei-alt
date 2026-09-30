local blink = require('blink.cmp')

-- blink.cmp configuration
blink.setup({
  keymap = { preset = 'default' },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = 'mono'
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer', 'minuet' },
    providers = {
      minuet = {
        name = 'minuet',
        module = 'minuet.blink',
        async = true,
        -- Must match minuet request_timeout (seconds) * 1000
        timeout_ms = 3000,
        score_offset = 50,
      },
    },
  },
  -- Recommended by minuet: no prefetch spam while typing
  completion = { trigger = { prefetch_on_insert = false } },
  signature = { enabled = true }
})

local capabilities = blink.get_lsp_capabilities()

-- Helper for Neovim 0.11+ LSP config
local function setup_lsp(name, config)
  config = config or {}
  config.capabilities = vim.tbl_deep_extend('force', capabilities, config.capabilities or {})
  
  -- Use Neovim 0.11+ native config if available, fallback to nvim-lspconfig
  if vim.lsp.config then
    vim.lsp.config[name] = config
    vim.lsp.enable(name)
  else
    require('lspconfig')[name].setup(config)
  end
end

-- Nix (nil)
setup_lsp('nil_ls')

-- Lua
setup_lsp('lua_ls', {
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
      workspace = { checkThirdParty = false },
      telemetry = { enabled = false },
    },
  },
})

-- Python (pyright + ruff)
setup_lsp('pyright')
setup_lsp('ruff')

-- Rust
setup_lsp('rust_analyzer', {
  settings = {
    ["rust-analyzer"] = {
      check = { command = "clippy" },
      cargo = { buildScripts = { enable = true }, features = "all" },
      procMacro = { enable = true },
      rustfmt = { rangeFormatting = { enable = true } },
      inlayHints = {
        bindingModeHints = { enable = true },
        chainingHints = { enable = true },
        closingBraceHints = { enable = true },
        closureCaptureHints = { enable = true },
        closureReturnTypeHints = { enable = "always" },
        closureStyle = "impl_fn",
        discriminantHints = { enable = "always" },
        expressionAdjustmentHints = { enable = "always" },
        implicitDrops = { enable = true },
        lifetimeElisionHints = { enable = "always", useParameterNames = true },
        parameterHints = { enable = true },
        reborrowHints = { enable = "always" },
        typeHints = { enable = true },
      },
    },
  },
})

-- Deno
setup_lsp('denols', {
  init_options = {
    enable = true,
    unstable = true,
    inlayHints = {
      functionLikeReturnTypes = { enabled = true },
      parameterNames = { enabled = "literals" },
      propertyDeclarationTypes = { enabled = true },
    },
  },
  root_dir = vim.fs.root(0, {"deno.json", "deno.jsonc"}),
})

-- YAML & TOML
setup_lsp('yamlls')
setup_lsp('taplo')

-- Shell
setup_lsp('bashls')
setup_lsp('fish_lsp')

-- Go
setup_lsp('gopls')

-- JS/TS/JSON + HTML/CSS
setup_lsp('biome')
setup_lsp('html')
setup_lsp('cssls')
setup_lsp('jsonls')

-- Ops
setup_lsp('dockerls')
setup_lsp('helm_ls')
setup_lsp('just')
setup_lsp('ansiblels')
setup_lsp('hyprls')

-- Markdown
setup_lsp('marksman')
setup_lsp('markdown_oxide')

-- Show inlay hints
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})

-- Formatting via conform-nvim (format on save).
-- Binaries come from programs.neovim.extraPackages (Nix store), nothing is downloaded.
require('conform').setup({
  formatters_by_ft = {
    nix = { 'nixfmt' },
    lua = { 'stylua' },
    python = { 'ruff_format' }, -- 4 spaces: ruff/PEP8 standard, not 2
    rust = { 'rustfmt' },
    javascript = { 'deno_fmt', 'biome', stop_after_first = true },
    typescript = { 'deno_fmt', 'biome', stop_after_first = true },
    javascriptreact = { 'deno_fmt', 'biome', stop_after_first = true },
    typescriptreact = { 'deno_fmt', 'biome', stop_after_first = true },
    json = { 'deno_fmt', 'biome', stop_after_first = true },
    toml = { 'taplo' },
    yaml = { 'yamlfmt' },
    sh = { 'shfmt' },
  },
  formatters = {
    -- nixfmt width 120
    nixfmt = { prepend_args = { '--width', '120' } },
    -- 2 spaces everywhere (stylua default is tabs)
    stylua = { prepend_args = { '--indent-type', 'Spaces', '--indent-width', '2' } },
    -- rustfmt indent 2 (edition left to rustfmt/Cargo.toml autodetect)
    rustfmt = { prepend_args = { '--config', 'tab_spaces=2' } },
    -- shfmt default is tabs
    shfmt = { prepend_args = { '-i', '2' } },
    -- Deno projects (deno.json*) format with deno, everything else with biome
    deno_fmt = {
      condition = function(_, ctx)
        return vim.fs.find({ 'deno.json', 'deno.jsonc' }, { path = vim.fs.dirname(ctx.filename), upward = true })[1] ~= nil
      end,
    },
    biome = {
      condition = function(_, ctx)
        return vim.fs.find({ 'deno.json', 'deno.jsonc' }, { path = vim.fs.dirname(ctx.filename), upward = true })[1] == nil
      end,
    },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = 'fallback',
  },
})

-- Neuro-autocomplete (minuet-ai) via blink.cmp.
-- Model "Muse Spark 1.3 Contributor" on the Opencode Go endpoint,
-- key comes from sops at runtime (path injected from Nix, value never in repo).
-- If the model slug is rejected by the API, pick a valid one with :Minuet change_model.
--
-- Opencode Go requires an `x-opencode-session` header with a stable session id
-- per conversation (routing + prompt caching), otherwise streaming fails with
-- MissingSessionID. The id lives in stdpath('data') (outside the repo).
local function opencode_session_id()
  local path = vim.fn.stdpath('data') .. '/minuet-opencode-session'
  local f = io.open(path, 'r')
  local sid = f and (f:read('*l') or '') or ''
  if f then
    f:close()
  end
  sid = vim.trim(sid)
  if sid == '' then
    sid = vim.fn.sha256(os.time() .. '-' .. vim.fn.getpid() .. '-' .. math.random()):sub(1, 32)
    vim.fn.writefile({ sid }, path)
    pcall(vim.fn.setfperm, path, 'rw-------')
  end
  return sid
end
local opencode_sid = opencode_session_id()

require('minuet').setup({
  provider = 'openai_compatible',
  request_timeout = 2.5,
  throttle = 1500,
  debounce = 600,
  -- Identify the client instead of the default generic curl UA
  curl_extra_args = { '-A', 'minuet-nvim' },
  provider_options = {
    openai_compatible = {
      api_key = function()
        local path = vim.g.minuet_api_key_file or ''
        local f = io.open(path, 'r')
        if not f then
          return ''
        end
        local key = f:read('*l') or ''
        f:close()
        return vim.trim(key)
      end,
      end_point = 'https://opencode.ai/zen/go/v1/chat/completions',
      model = 'muse-spark-1.3-contributor',
      name = 'Muse Spark',
      transform = {
        function(data)
          data.headers['x-opencode-session'] = opencode_sid
          return data
        end,
      },
      optional = {
        max_tokens = 56,
        top_p = 0.9,
      },
    },
  },
})

-- Diagnostic UI
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
