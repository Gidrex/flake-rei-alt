{ pkgs, ... }:
let
  # Force the PipeWire graph (and so the KA11) to the playing file's sample rate; unset on exit.
  # Rates mirror allowed-rates in pipewire.nix (= what the KA11 supports); others fall back to the default clock.
  # Shipped via programs.mpv.scripts (wrapper --script=) so it also loads under --load-scripts=no (riptide).
  # shortcut: last mpv to start/quit wins with several instances; upgrade to per-instance tracking if that bites.
  # pw-metadata comes from the host PipeWire.
  pwForceRate = pkgs.writeTextDir "share/mpv/scripts/pw-force-rate.lua" ''
    local ok = { [44100]=1, [48000]=1, [88200]=1, [96000]=1, [176400]=1, [192000]=1, [352800]=1, [384000]=1 }
    local function force(rate)
      mp.command_native({ name = "subprocess", playback_only = false,
        args = { "pw-metadata", "-n", "settings", "0", "clock.force-rate", tostring(rate) } })
    end
    mp.observe_property("audio-params/samplerate", "number", function(_, r)
      if r then force(ok[r] and r or 0) end
    end)
    mp.register_event("shutdown", function() force(0) end)
  '';
in
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

      # Audio: via PipeWire, shared with other apps, FP3 AutoEq smart filter in front of the KA11 (pipewire.nix).
      # pw-force-rate.lua pins the graph to the file's rate, so mpv is never resampled (other apps are instead).
      # Keep volume at 100: mpv's own volume is an extra software stage.
      ao = "pipewire";
      # Float out: mpv's software volume (riptide drives it) is applied in float, not requantized to s16 undithered.
      # PipeWire runs float32 internally anyway.
      audio-format = "float";
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
      (pwForceRate // { scriptName = "pw-force-rate.lua"; })
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
