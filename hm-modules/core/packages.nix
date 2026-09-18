# Shared CLI/TUI packages, grouped by area. Machine-specific additions
# belong to machines/<name>/default.nix, not here.
{ pkgs, ... }:
{
  home.packages =
    (with pkgs; [
      # secrets & nix tooling
      age
      nix-prefetch-github
      sops
      ssh-to-age

      # files & archives
      chafa
      duckdb
      hexyl
      libqalculate
      mediainfo
      poppler
      rip2
      ripdrag
      tldr
      ueberzugpp
      unrar

      # terminal UX
      glow
      gum

      # web
      bind.dnsutils # provides dig and host
      ipfetch
      speedtest-cli

      # dev
      deno
      just
      lazydocker
      lazyjj
      mosquitto

      # apps
      ytfzf

      # ml
      easyocr
    ])
    ++ (with pkgs.nerd-fonts; [
      arimo
      caskaydia-mono
      geist-mono
      jetbrains-mono
      sauce-code-pro
      symbols-only
    ])
    ++ (with pkgs; [ times-newer-roman ]);
}
