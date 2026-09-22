# External yazi plugins (no docs/screenshots), passed as `yazi-plugins`.
{ lib, inputs }:
let
  # Suffix-only filter: fast, drops docs/screenshots.
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
