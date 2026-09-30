{
  pkgs,
  config,
  ...
}:
{
  catppuccin.nvim.enable = false;

  programs.neovim = {
    enable = true;
    defaultEditor = false;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      render-markdown-nvim
      plenary-nvim
      aerial-nvim
      nvim-treesitter.withAllGrammars
      lualine-nvim
      indent-blankline-nvim
      which-key-nvim
      gitsigns-nvim
      diffview-nvim
      mini-nvim
      snacks-nvim
      conform-nvim
      minuet-ai-nvim
      friendly-snippets

      # Debugging
      nvim-dap
      nvim-dap-ui
      nvim-nio # required by nvim-dap-ui

      # Diagnostics list
      trouble-nvim

      # LSP & Completion
      nvim-lspconfig
      blink-cmp
    ];

    extraPackages = with pkgs; [
      # Nix
      nil # Nix
      nixfmt

      # Lua
      lua-language-server
      stylua

      # Python
      python3
      pyright # Python
      ruff # Python linter/formatter
      ty # Python type checker wrapper
      python313Packages.debugpy # DAP adapter (python3 -m debugpy.adapter)

      # Rust
      rust-analyzer
      rustfmt
      vscode-extensions.vadimcn.vscode-lldb # DAP adapter (codelldb, MIT)

      # JS/TS/JSON + HTML/CSS
      deno
      biome
      vscode-langservers-extracted

      # Shell
      bash-language-server
      fish-lsp
      shfmt

      # TOML
      taplo # TOML
      tombi

      # YAML
      yaml-language-server
      yamlfmt

      # Markdown
      markdown-oxide
      marksman

      # Go
      gopls
      delve # DAP adapter (dlv dap)

      # Ops tooling
      dockerfile-language-server
      helm-ls
      just-lsp
      ansible-language-server
      hyprls

      # AI completion HTTP (minuet-ai)
      curl
    ];

    initLua = ''
      -- sops secret path only (the value never lands in the store)
      vim.g.minuet_api_key_file = "${config.sops.secrets.opencode_api_key.path}";
      -- CodeLLDB adapter binary (MIT, from nixpkgs)
      vim.g.codelldb_path = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
      require('init')
    '';
  };

  # Lua config symlink
  xdg.configFile."nvim/lua".source = ./lua;
}
