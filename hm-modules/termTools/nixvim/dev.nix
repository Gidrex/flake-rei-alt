{ ... }:
{
  programs.nixvim.plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        keymap.preset = "default";
        appearance = {
          use_nvim_cmp_as_default = true;
          nerd_font_variant = "mono";
        };
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
            "minuet"
          ];
          providers.minuet = {
            name = "minuet";
            module = "minuet.blink";
            async = true;
            timeout_ms = 3000;
            score_offset = 50;
          };
        };
        completion.trigger.prefetch_on_insert = false;
        signature.enabled = true;
      };
    };

    conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          nix = [ "nixfmt" ];
          lua = [ "stylua" ];
          python = [ "ruff_format" ]; # 4 spaces: ruff/PEP8 standard, not 2
          rust = [ "rustfmt" ];
          javascript = [
            "deno_fmt"
            "biome"
          ];
          typescript = [
            "deno_fmt"
            "biome"
          ];
          javascriptreact = [
            "deno_fmt"
            "biome"
          ];
          typescriptreact = [
            "deno_fmt"
            "biome"
          ];
          json = [
            "deno_fmt"
            "biome"
          ];
          toml = [ "taplo" ];
          yaml = [ "yamlfmt" ];
          sh = [ "shfmt" ];
        };
        formatters = {
          nixfmt.prepend_args = [
            "--width"
            "120"
          ];
          stylua.prepend_args = [
            "--indent-type"
            "Spaces"
            "--indent-width"
            "2"
          ];
          rustfmt.prepend_args = [
            "--config"
            "tab_spaces=2"
          ];
          shfmt.prepend_args = [
            "-i"
            "2"
          ];
          # Deno projects use deno, rest use biome.
          deno_fmt.condition.__raw = "require('format-cond').is_deno";
          biome.condition.__raw = "require('format-cond').is_not_deno";
        };
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
      };
      # No manual bind by design
      lazyLoad.settings.event = "BufWritePre";
    };

    dap.enable = true;
    dap-ui.enable = true;
  };
}
