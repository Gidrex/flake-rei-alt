{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    config = {
      # Video & Wayland
      vo = "gpu,wlshm";
      gpu-context = "wayland";
      hwdec = "auto-safe";
      profile = "gpu-hq";
      force-window = "immediate";

      # Quality
      scale = "ewa_lanczossharp";
      cscale = "ewa_lanczossharp";
      dscale = "mitchell";
      interpolation = "yes";
      video-sync = "display-resample";
      tscale = "oversample";

      # Audio: via PipeWire so the FP3 AutoEq smart filter (pipewire.nix) sits in front of the KA11; the DAC follows
      # the file's rate (allowed-rates), so no resampling unless another stream holds the clock at a different rate.
      # Keep volume at 100: mpv's own volume is an extra software stage.
      ao = "pipewire";
      audio-channels = "stereo";
      gapless-audio = "yes";

      # General
      volume = 100;
      volume-max = 130;
      replaygain = "no";
      save-position-on-quit = "yes";
      keep-open = "yes";

      # Subtitles & UI
      sub-auto = "fuzzy";
      sub-font = "SauceCodePro Nerd Font Mono";
      sub-font-size = 36;
      osd-font = "SauceCodePro Nerd Font Mono";
      osd-bar = "no";
      border = "no";
    };

    scripts = with pkgs.mpvScripts; [
      mpris
      uosc
      thumbfast
    ];

    scriptOpts = {
      uosc = {
        top_bar = "always";
        top_bar_controls = "yes";
        top_bar_title = "yes";
        click_threshold = 250;
        double_click_threshold = 300;
      };
    };
  };

}
