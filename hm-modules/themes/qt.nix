{ pkgs, ... }:
{
  qt = {
    platformTheme.name = "kvantum";
    style.name = "kvantum";
    style.package = pkgs.libsForQt5.qtstyleplugins;
  };
}
