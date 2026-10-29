# Finding and navigating: file search, fuzzy finders, ls replacements.
{ pkgs, ... }:
{
  programs = {
    zoxide.enable = true;

    fzf = {
      enable = true;
      defaultCommand = "${pkgs.fd}/bin/fd --type f";
    };

    skim.enable = true;

    television = {
      enable = true;
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
