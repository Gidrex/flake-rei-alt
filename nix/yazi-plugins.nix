# External (non-nixpkgs) yazi plugins, cleaned of docs/screenshots.
# Result is passed to home-manager modules via extraSpecialArgs as `yazi-plugins`.
{ lib, inputs }:
let
  # Suffix-only filter: fast (no builtins.readDir per path during eval) and
  # sufficient — leftover empty dirs are harmless, docs/screenshots are the bloat.
  excludedNames = [
    "LICENSE"
    "README"
  ];
  excludedSuffixes = [
    ".md"
    ".png"
    ".jpg"
    ".jpeg"
  ];

  cleanYaziPlugin =
    src:
    lib.cleanSourceWith {
      inherit src;
      filter =
        path: _type:
        let
          baseName = baseNameOf path;
        in
        !(builtins.elem baseName excludedNames || lib.any (suffix: lib.hasSuffix suffix baseName) excludedSuffixes);
    };
in
builtins.mapAttrs (_: cleanYaziPlugin) {
  inherit (inputs) open-with-cmd close-and-restore-tab;
}
