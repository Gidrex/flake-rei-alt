# Catppuccin mocha, auto-enabled. Opt-outs live in app modules.
{ vars, ... }:
{
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = vars.theme.flavor;
    accent = vars.theme.accent;
    foot.enable = false;
  };
}
