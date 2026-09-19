# Global theme: catppuccin mocha, auto-enabled for all supported apps.
# Per-app opt-outs live in the app's own module (e.g. kitty), not here.
{ vars, ... }:
{
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = vars.theme.flavor;
    accent = vars.theme.accent;
    foot.enable = false;
    # gtk = {
    #   icon.enable = true;
    #   icon.accent = "sky";
    # };
  };
}
