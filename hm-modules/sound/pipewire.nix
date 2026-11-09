{
  # Let PipeWire switch the DAC to the source rate instead of resampling everything to 48 kHz.
  # Rates the sink doesn't support (e.g. >96k on the built-in card) are skipped automatically.
  xdg.configFile."pipewire/pipewire.conf.d/10-allowed-rates.conf".text = ''
    context.properties = {
      default.clock.allowed-rates = [ 44100 48000 88200 96000 176400 192000 352800 384000 ]
    }
  '';

  # FiiO FP3 AutoEq (Jaytiss measurement, AutoEq results/Jaytiss/in-ear/FiiO FP3) as a WirePlumber
  # smart filter: inserted only in front of the KA11, matched by card name (node.name changes with UAC mode).
  xdg.configFile."wireplumber/wireplumber.conf.d/50-fp3-eq.conf".text = ''
    wireplumber.profiles = {
      main = { filter.sink.fp3-eq = required }
    }
    wireplumber.components = [
      {
        name = libpipewire-module-filter-chain, type = pw-module-client
        arguments = {
          node.name = "filter.sink.fp3-eq"
          node.description = "FP3 AutoEq"
          media.name = "FP3 AutoEq"
          filter.graph = {
            nodes = [
              {
                type = builtin
                name = eq
                label = param_eq
                config = { filename = "${./fiio-fp3-autoeq.txt}" }
              }
            ]
            inputs = [ "eq:In 1" "eq:In 2" ]
            outputs = [ "eq:Out 1" "eq:Out 2" ]
          }
          audio.channels = 2
          audio.position = [ FL FR ]
          capture.props = {
            media.class = Audio/Sink
            filter.smart = true
            filter.smart.name = "filter.sink.fp3-eq"
            filter.smart.target = { alsa.card_name = "FIIO KA11" }
          }
          playback.props = {
            node.passive = true
            media.role = "DSP"
          }
        }
        provides = filter.sink.fp3-eq
        requires = [ support.client-context ]
      }
    ]
  '';
}
