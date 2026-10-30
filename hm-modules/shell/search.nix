# Finding and navigating: file search, fuzzy finders, ls replacements.
{ pkgs, ... }:
{
  programs = {
    zoxide.enable = true;

    fzf = {
      enable = true;
      enableFishIntegration = false;
      defaultCommand = "${pkgs.fd}/bin/fd --type f";
    };

    skim = {
      enable = true;
      enableFishIntegration = true;
    };

    television = {
      enable = true;
      enableFishIntegration = false;
      # NOTE: any non-empty settings makes HM own
      # ~/.config/television/config.toml, so the hand-set theme is mirrored here.
      settings = {
        ui = {
          theme = "catppuccin-mocha-blue";
          status_bar.hidden = true;
          help_panel.hidden = true;
          remote_control.hidden = true;
        };
      };
      # Upstream prototype (cable/unix/fish-history.toml): feeds the Ctrl+R
      # history picker wired by `tv init fish`. Without it tv errors with
      # "Channel not found: fish-history".
      channels."fish-history" = {
        metadata = {
          name = "fish-history";
          description = "A channel to select from your fish history";
          requirements = [ "fish" ];
        };
        source = {
          command = "fish -c 'history'";
          no_sort = true;
          frecency = false;
        };
      };
    };

    fd = {
      enable = true;
      ignores = [ ".git/" ];
    };

    ripgrep = {
      enable = true;
      arguments = [
        "--colors=line:style:bold"
        "--colors=match:fg:yellow"
        "--colors=match:style:bold"
        "--colors=path:fg:cyan"
        "--colors=path:style:bold"
        "--smart-case"
        "--hidden"
        "--follow"
        "--no-line-number"
      ];
    };

    eza = {
      enable = true;
      icons = "auto";
      git = true;
      extraOptions = [
        "--oneline"
        "--group-directories-first"
      ];
    };
  };
}
