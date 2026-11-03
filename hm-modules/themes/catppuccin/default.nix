# Catppuccin mocha (accent blue), vendored. Files are the upstream ports as catppuccin/nix rendered them;
# the flake input is gone to drop its whiskers build and import-from-derivation.
{ lib, ... }:
{
  xdg.configFile = {
    "eza/theme.yml".source = ./eza.yml;
    "fish/themes/catppuccin-mocha.theme".source = ./fish.theme;
    "helix/themes/catppuccin-mocha.toml".source = ./helix.toml;
    "television/themes/catppuccin-mocha-blue.toml".source = ./television.toml;
    "yazi/theme.toml".source = ./yazi.toml;
    # yazi.toml points its code highlighter at this path.
    "yazi/Catppuccin-mocha.tmTheme".source = ./yazi.tmTheme;
  };

  home.sessionVariables = {
    FZF_DEFAULT_OPTS_FILE = "${./fzf.rc}";
    GLAMOUR_STYLE = "${./glamour.json}";
  };

  programs = {
    fish.shellInit = ''
      fish_config theme choose "catppuccin-mocha"
    '';
    foot.settings.main.include = "${./foot.ini}";
    helix.settings = {
      theme = "catppuccin-mocha";
      editor.color-modes = lib.mkDefault true;
    };
    # Theme ships with nixpkgs kitty-themes.
    kitty.themeFile = "Catppuccin-Mocha";
    mpv.config.include = "${./mpv.conf}";
    skim.defaultOptions = [
      "--color=fg:#cdd6f4,bg:#1e1e2e,matched:#313244,matched_bg:#f2cdcd,current:#cdd6f4,current_bg:#45475a,current_match:#1e1e2e,current_match_bg:#f5e0dc,spinner:#a6e3a1,info:#cba6f7,prompt:#89b4fa,cursor:#f38ba8,selected:#eba0ac,header:#94e2d5,border:#6c7086"
    ];
    television.settings.ui.theme = "catppuccin-mocha-blue";
  };
}
