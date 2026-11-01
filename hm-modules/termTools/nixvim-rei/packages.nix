# Binaries only; configs in lsp.nix/dev.nix.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.nixvim-rei;
in
{
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      extraPlugins = with pkgs.vimPlugins; [
        plenary-nvim # required by gitsigns/diffview
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
        tree-sitter # CLI for nvim-treesitter health (:TSInstall); grammars ship via nixvim

        # Python (pyright types, ruff lints; ty not wired anywhere)
        python3
        pyright
        ruff
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

        # TOML (taplo serves + formats; tombi was never wired)
        taplo

        # YAML
        yaml-language-server
        yamlfmt

        # Markdown (oxide only, matches the single lsp server)
        markdown-oxide

        # Go
        gopls
        delve # DAP adapter (dlv dap)

        # Ops tooling
        dockerfile-language-server
        helm-ls
        just-lsp
        ansible-language-server
        hyprls
      ];
    };
  };
}
