# package = null pins system binaries (see packages.nix).
# Set inner settings only; nixvim wraps them with the server key.
{ config, lib, ... }:
let
  cfg = config.programs.nixvim-rei;
in
{
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.lsp = {
      enable = true;
      servers = {
        nil_ls = {
          enable = true;
          package = null;
        };
        lua_ls = {
          enable = true;
          package = null;
          settings = {
            diagnostics.globals = [ "vim" ];
            workspace.checkThirdParty = false;
            telemetry.enabled = false;
          };
        };
        pyright = {
          enable = true;
          package = null;
        };
        ruff = {
          enable = true;
          package = null;
        };
        rust_analyzer = {
          enable = true;
          installRustc = false; # rustc/cargo come from rustup, not Nixvim
          installCargo = false;
          settings = {
            check.command = "clippy";
            cargo = {
              buildScripts.enable = true;
            };
            procMacro.enable = true;
            rustfmt.rangeFormatting.enable = true;
            inlayHints = {
              bindingModeHints.enable = true;
              chainingHints.enable = true;
              closingBraceHints.enable = true;
              closureCaptureHints.enable = true;
              closureReturnTypeHints.enable = "always";
              closureStyle = "impl_fn";
              discriminantHints.enable = "always";
              expressionAdjustmentHints.enable = "always";
              implicitDrops.enable = true;
              lifetimeElisionHints = {
                enable = "always";
                useParameterNames = true;
              };
              parameterHints.enable = true;
              reborrowHints.enable = "always";
              typeHints.enable = true;
            };
          };
        };
        denols = {
          enable = true;
          package = null;
        };
        yamlls = {
          enable = true;
          package = null;
        };
        taplo = {
          enable = true;
          package = null;
        };
        bashls = {
          enable = true;
          package = null;
        };
        fish_lsp = {
          enable = true;
          package = null;
        };
        gopls = {
          enable = true;
          package = null;
        };
        biome = {
          enable = true;
          package = null;
        };
        html = {
          enable = true;
          package = null;
        };
        cssls = {
          enable = true;
          package = null;
        };
        jsonls = {
          enable = true;
          package = null;
        };
        dockerls = {
          enable = true;
          package = null;
        };
        helm_ls = {
          enable = true;
          package = null;
        };
        just = {
          enable = true;
          package = null;
        };
        ansiblels = {
          enable = true;
          package = null;
        };
        hyprls = {
          enable = true;
          package = null;
        };
        # Single markdown server (oxide covers notes + Obsidian links).
        markdown_oxide = {
          enable = true;
          package = null;
        };
      };
    };
  };
}
