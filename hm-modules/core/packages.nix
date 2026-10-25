# Shared packages by area; machine extras in machines/<name>.
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
      fvm
      just
      lazydocker
      lazyjj
      rtk
      scc
      uv

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
