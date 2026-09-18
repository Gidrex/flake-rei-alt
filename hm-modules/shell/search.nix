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

    fd = {
      enable = true;
      extraOptions = [ "--absolute-path" ];
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
