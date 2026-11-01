{ pkgs }:
let
  # Archify skill bundle (v3.2.0); sparse checkout keeps the store small.
  # Bump rev to update.
  archifySkill = pkgs.fetchFromGitHub {
    owner = "tt-a1i";
    repo = "archify";
    tag = "v3.2.0";
    hash = "sha256-XG4I34/7FR9LVoOQn1S7dBJOFvmemWNLPrSdj+8O01Q=";
    sparseCheckout = [ "archify" ];
  };
in
{
  python-uv = ./skills/python-uv;
  typescript-biome = ./skills/typescript-biome;
  rust-cargo = ./skills/rust-cargo;
  flutter-dart = ./skills/flutter-dart;
  nix-hm = ./skills/nix-hm;
  lua-shell = ./skills/lua-shell;
  ctx7-docs = ./skills/ctx7-docs;
  rtk = ./skills/rtk;
  chora = ./skills/chora;
  archify = "${archifySkill}/archify";
}
