# Shared packages by area; machine extras in machines/<name>.
{ pkgs, ... }:
{
  home.packages =
    (with pkgs; [
      # secrets & nix tooling
      age
      nix-output-monitor
      nix-prefetch-github
      nvd
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
      (writeShellApplication {
        name = "drag";
        # niri comes from the host (not nixpkgs), found via the inherited PATH.
        runtimeInputs = [
          blobdrop
          jq
        ];
        text = builtins.readFile ./drag.sh;
      })
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
