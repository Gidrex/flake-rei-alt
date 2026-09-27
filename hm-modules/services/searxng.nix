# Local SearXNG service; secret rendered at activation, never in store.
{ config, pkgs, ... }:
{
  sops.secrets.searx_secret_key = { };

  sops.templates."searxng-settings.yml" = {
    content = ''
      # Google off by default upstream; re-enable with headroom.
      use_default_settings:
        engines:
          remove:
            - startpage
            - ecosia
      engines:
        - name: google
          disabled: false
          timeout: 3.0
      search:
        autocomplete: "google" # suggestions as you type
        autocomplete_min: 2
        favicon_resolver: "duckduckgo" # icons near results
      plugins:
        searx.plugins.infinite_scroll.SXNGPlugin:
          active: true
      ui:
        results_on_new_tab: true
        theme_args:
          simple_style: dark
      outgoing:
        request_timeout: 1.5
      server:
        bind_address: "127.0.0.1"
        port: 8888
        image_proxy: true # proxy images, hide IP
        secret_key: "${config.sops.placeholder.searx_secret_key}"
    '';
    path = "${config.xdg.configHome}/searxng/settings.yml";
  };

  systemd.user.services.searxng = {
    Unit = {
      Description = "SearXNG metasearch engine";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${pkgs.searxng}/bin/searxng-run";
      Environment = "SEARXNG_SETTINGS_PATH=${config.xdg.configHome}/searxng/settings.yml";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
