# Local SearXNG service; secret rendered at activation, never in store.
{ config, pkgs, ... }:
{
  sops.secrets.searx_secret_key = { };

  sops.templates."searxng-settings.yml" = {
    content = ''
      # google scraping banned from a single IP; use google cse instead.
      # brave scraping 429s without an API key (needs card); disabled, not
      # removed: brave.images/videos/news share network "brave" and crash
      # startup with KeyError when it is removed entirely.
      use_default_settings:
        engines:
          remove:
            - startpage
            - ecosia
            - google
      engines:
        - name: brave
          disabled: true
        - name: brave.images
          disabled: true
        - name: brave.videos
          disabled: true
        - name: brave.news
          disabled: true
        - name: qwant
          disabled: false
        - name: mojeek
          inactive: false
          disabled: false
          timeout: 6.0 # Altcha PoW challenge needs room
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
