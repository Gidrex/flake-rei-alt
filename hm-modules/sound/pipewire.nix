{
  # Let PipeWire switch the DAC to the source rate instead of resampling everything to 48 kHz.
  # Rates the sink doesn't support (e.g. >96k on the built-in card) are skipped automatically.
  xdg.configFile."pipewire/pipewire.conf.d/10-allowed-rates.conf".text = ''
    context.properties = {
      default.clock.allowed-rates = [ 44100 48000 88200 96000 176400 192000 352800 384000 ]
    }
  '';
}
