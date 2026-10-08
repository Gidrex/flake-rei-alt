# Catppuccin mocha, auto-enabled. Do not hand-roll colors per app.
{ vars, ... }:
{
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = vars.theme.flavor;
    accent = vars.theme.accent;
  };
}
