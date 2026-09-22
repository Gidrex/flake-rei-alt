# Declarative opencode; auth resolves at runtime from sops (path only in store).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Pin 1.18.29: .30 crashes (upstream bun bug, nixpkgs#563241).
  opencodePkg = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "opencode";
    version = "1.18.29";

    src = pkgs.fetchurl {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
      hash = "sha256-6oALf/ViJrcJUhJsn8HiUXykxLVoL9nT+eh0SWl6EZQ=";
    };

    sourceRoot = ".";

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall
      install -Dm755 opencode $out/bin/opencode
      wrapProgram $out/bin/opencode \
        --prefix PATH : ${lib.makeBinPath [ pkgs.ripgrep ]} \
        --set OPENCODE_DISABLE_AUTOUPDATE true
      runHook postInstall
    '';

    meta = {
      description = "AI coding agent built for the terminal";
      homepage = "https://github.com/anomalyco/opencode";
      mainProgram = "opencode";
    };
  };
in
{
  programs.opencode = {
    enable = true;
    package = opencodePkg;
    enableMcpIntegration = true;
    # AGENTS.md auto-loaded by every session
    context = ./AGENTS.md;
    # Skills on demand via `skill` tool
    skills = {
      python-uv = ./skills/python-uv;
      typescript-biome = ./skills/typescript-biome;
      rust-cargo = ./skills/rust-cargo;
      flutter-dart = ./skills/flutter-dart;
      nix-hm = ./skills/nix-hm;
      lua-shell = ./skills/lua-shell;
      ctx7-docs = ./skills/ctx7-docs;
    };
    settings = {
      # Self-update off: nix owns the binary.
      autoupdate = false;
      lsp = true;
      provider = {
        "opencode-go" = {
          options = {
            apiKey = "{file:${config.sops.secrets.opencode_api_key.path}}";
          };
        };
        "openrouter" = {
          options = {
            apiKey = "{file:${config.sops.secrets.openrouter_api_key.path}}";
          };
        };
      };
    };
    # TUI theme (mkForce over catppuccin default).
    tui = {
      theme = lib.mkForce "catppuccin-macchiato";
    };
  };

  # Force ANSI colors (no `plugins` option, placed directly).
  xdg.configFile."opencode/plugins/force-color.ts".source = ./plugins/force-color.ts;
}
