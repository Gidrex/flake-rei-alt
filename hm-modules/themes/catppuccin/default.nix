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

  # Tauon is a Flatpak without /nix access, so a store symlink would dangle inside the sandbox: copy instead.
  home.activation.tauonTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dir="$HOME/.var/app/com.github.taiko2k.tauonmb/data/TauonMusicBox/theme"
    run install -Dm644 ${./tauon.ttheme} "$dir/Catppuccin Mocha.ttheme"
    run install -Dm644 ${./tauon-lavender.ttheme} "$dir/Catppuccin Mocha Lavender.ttheme"
  '';

  home.sessionVariables = {
    FZF_DEFAULT_OPTS_FILE = "${./fzf.rc}";
    GLAMOUR_STYLE = "${./glamour.json}";
  };

  programs = {
    fish.shellInit = ''
      fish_config theme choose "catppuccin-mocha"
    '';
    foot.settings.main.include = "${./foot.ini}";
    # Same palette as foot.ini.
    ghostty = {
      settings.theme = "catppuccin-mocha";
      themes.catppuccin-mocha = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        cursor-color = "#f5e0dc";
        cursor-text = "#11111b";
        selection-background = "#414356";
        selection-foreground = "#cdd6f4";
        palette = [
          "0=#45475a"
          "1=#f38ba8"
          "2=#a6e3a1"
          "3=#f9e2af"
          "4=#89b4fa"
          "5=#f5c2e7"
          "6=#94e2d5"
          "7=#bac2de"
          "8=#585b70"
          "9=#f38ba8"
          "10=#a6e3a1"
          "11=#f9e2af"
          "12=#89b4fa"
          "13=#f5c2e7"
          "14=#94e2d5"
          "15=#a6adc8"
          "16=#fab387"
          "17=#f5e0dc"
        ];
      };
    };
    helix.settings = {
      theme = "catppuccin-mocha";
      editor.color-modes = lib.mkDefault true;
    };
    # Theme ships with nixpkgs kitty-themes.
    kitty.themeFile = "Catppuccin-Mocha";
    mpv.config.include = "${./mpv.conf}";
    # snacks.image renders mermaid blocks with mmdc; base theme + mocha palette.
    nixvim.plugins.snacks.settings.image.convert.mermaid.__raw = ''
      function()
        -- 1.3x the terminal scale: snacks shows the PNG at its pixel size.
        local scale = (Snacks.image.terminal.size().scale or 1) * 1.3
        return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-c", "${./mermaid.json}", "-s", tostring(scale) }
      end
    '';
    skim.defaultOptions = [
      "--color=fg:#cdd6f4,bg:#1e1e2e,matched:#313244,matched_bg:#f2cdcd,current:#cdd6f4,current_bg:#45475a,current_match:#1e1e2e,current_match_bg:#f5e0dc,spinner:#a6e3a1,info:#cba6f7,prompt:#89b4fa,cursor:#f38ba8,selected:#eba0ac,header:#94e2d5,border:#6c7086"
    ];
    television.settings.ui.theme = "catppuccin-mocha-blue";
  };
}
