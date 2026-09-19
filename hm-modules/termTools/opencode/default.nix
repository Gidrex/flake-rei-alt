# Declarative opencode: pinned binary + managed config, no curl installer.
# Auth for the managed `opencode-go` provider resolves at runtime from the
# sops secret file — only the path lands in the nix store, never the key.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Pin opencode to 1.18.29: nixpkgs 1.18.30 has a known upstream bun runtime bug
  # (nixpkgs#563241: TypeError: undefined is not an object (evaluating 'a.name'))
  # causing crashes in SystemPrompt.environment when sending prompts.
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
    # Global rules: ./AGENTS.md lands at ~/.config/opencode/AGENTS.md,
    # auto-loaded by every session
    context = ./AGENTS.md;
    # Global skills: ./skills/<name>/ lands at ~/.config/opencode/skills/<name>/,
    # loaded on demand via the `skill` tool (see AGENTS.md router).
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
      # nix owns the binary; self-update would fight the package manager.
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
    # Currently selected TUI theme (was only in local TUI state, kv.json).
    # mkForce: catppuccin/nix defaults this to "catppuccin" (mocha flavour).
    tui = {
      theme = lib.mkForce "catppuccin-macchiato";
    };
  };

  # Global plugin: force ANSI colors in shell tool output.
  # programs.opencode has no `plugins` option, so place the file directly.
  xdg.configFile."opencode/plugins/force-color.ts".source = ./plugins/force-color.ts;
}
