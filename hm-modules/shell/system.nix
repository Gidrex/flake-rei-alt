# System monitoring, downloads, image viewing, shell helpers.
{ ... }:
{
  programs = {
    home-manager.enable = true;
    nix-your-shell.enable = true;
    fastfetch.enable = true;

    aria2 = {
      enable = true;
      settings = {
        max-concurrent-downloads = 5;
        continue = true;
        max-connection-per-server = 4;
        min-split-size = "10M";
        split = 5;
      };
    };

    btop = {
      enable = true;
      settings = {
        color_theme = "horizon";
        show_gpu_info = true;
        vim_keys = true;
        proc_sorting = "memory";
        proc_gradient = false;
        proc_per_core = false;
        graph_symbol = "block";
        graph_symbol_cpu = "braille";
        graph_symbol_net = "braille";
        show_battery = false;
      };
    };

    imv = {
      settings.options = {
        list_files_at_exit = true;
        overlay_font = "Monospace:14";
      };
    };
  };
}
