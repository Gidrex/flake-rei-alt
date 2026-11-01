{ config, lib, ... }:
let
  cfg = config.programs.nixvim-rei;
in
{
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins = {
      blink-cmp = {
        enable = true;
        settings = {
          keymap = {
            # super-tab: Tab accepts (Helix/VSCode muscle memory).
            # Default preset only accepts via C-y; Tab/Enter do nothing.
            preset = "super-tab";
            # Manual menu: never pops while typing, Tab shows it.
            # select_and_accept falls through when the menu is hidden
            # (like select_next), so a hidden menu lands on show, and a
            # visible menu is accepted without an extra keypress.
            "<Tab>" = [
              {
                __raw = ''
                  function(cmp)
                    if cmp.snippet_active() then return cmp.accept()
                    elseif cmp.is_menu_visible() then return cmp.select_and_accept() end
                  end
                '';
              }
              "show"
              "snippet_forward"
              "fallback"
            ];
            # Up/Down navigate the menu, else move the cursor.
            "<Up>" = [
              {
                __raw = ''
                  function(cmp)
                    if cmp.is_menu_visible() then return cmp.select_prev() end
                  end
                '';
              }
              "fallback"
            ];
            "<Down>" = [
              {
                __raw = ''
                  function(cmp)
                    if cmp.is_menu_visible() then return cmp.select_next() end
                  end
                '';
              }
              "fallback"
            ];
            "<CR>" = [
              "accept"
              "fallback"
            ];
          };
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
              "chora-index"
            ];
            providers = {
              "chora-index" = {
                name = "Chora index";
                module = "chora-index";
              };
            };
          };
          completion = {
            # Manual-only: nothing pops while typing, Tab shows the menu.
            menu.auto_show = false;
            # Docs popup per item (signature, params, return type) while browsing.
            # Only appears after the menu was opened manually via Tab.
            documentation.auto_show = true;
            trigger = {
              prefetch_on_insert = false;
              show_in_snippet = false;
              show_on_keyword = false;
              show_on_trigger_character = false;
              show_on_insert_on_trigger_character = false;
              show_on_accept_on_trigger_character = false;
            };
          };
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
            # biome.json wins (matches `biome check --write`), deno_fmt only
            # for pure-deno projects without biome config.
            deno_fmt.condition.__raw = "require('format-cond').is_deno";
            biome.condition.__raw = "require('format-cond').is_biome";
          };
          # Special buffers (Diffview/gitsigns panels, preview floats) are never
          # formatted: :w there fails with E382 ('buftype' option is set), so
          # running formatters on BufWritePre is pure noise.
          format_on_save.__raw = ''
            function(bufnr)
              if vim.bo[bufnr].buftype ~= "" then
                return nil
              end
              if vim.api.nvim_buf_get_name(bufnr):find("^diffview://", 1, true) then
                return nil
              end
              return { timeout_ms = 500, lsp_format = "fallback" }
            end
          '';
        };
        # No manual bind by design
        lazyLoad.settings.event = "BufWritePre";
      };

      dap.enable = true;
      dap-ui.enable = true;
    };
  };
}
