# Binaries only; configs in lsp.nix/dev.nix.
{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      plenary-nvim # required by gitsigns/diffview
      minuet-ai-nvim # AI completion (setup in lua/minuet-setup.lua)
      friendly-snippets
      nvim-nio # required by nvim-dap-ui
    ];

    extraPackages = with pkgs; [
      # Nix
      nil
      nixfmt

      # Lua
      lua-language-server
      stylua

      # Python
      python3
      pyright
      ruff
      ty
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
      taplo
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
  };
}
