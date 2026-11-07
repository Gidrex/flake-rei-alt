# Local SearXNG service; secret rendered at activation, never in store.
# (searx_secret_key is declared centrally in hm-modules/security/sops.nix.)
{
  config,
  pkgs,
  vars,
  ...
}:
{
  sops.templates."searxng-settings.yml" = {
    content = ''
      # google scraping banned from a single IP; use google cse instead.
      # brave scraping 429s without an API key (needs card); disabled, not
      # removed: brave.images/videos/news share network "brave" and crash
      # startup with KeyError when it is removed entirely.
      # qwant 403s from a single IP (Datadome); upstream disables it by default.
      # yandex unreachable from here (curl timeouts on yandex.com/.ru) and
      # yandex api needs a cloud API key; ahmia/torch need tor, radio browser
      # fails DNS at init -- all disabled to cut startup/error noise.
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
          disabled: true
        - name: yandex
          disabled: true
        - name: "yandex api"
          disabled: true
        - name: ahmia
          disabled: true
        - name: torch
          disabled: true
        - name: "radio browser"
          disabled: true
        - name: bing
          disabled: false
        - name: swisscows
          disabled: false
        - name: mwmbl
          disabled: false
        - name: mojeek
          disabled: false
          timeout: 6.0 # Altcha PoW challenge needs room
        - name: wikidata
          timeout: 8.0 # SPARQL answers are slow, 1.5s-3s timeouts kill it
      search:
        autocomplete: "duckduckgo" # google scraping banned from a single IP
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
        request_timeout: 5.0
        max_request_timeout: 10.0
        retries: 1
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
      # Parses untrusted web HTML; needs only network + read of its settings.
      PrivateTmp = true;
      ProtectHome = "read-only";
    }
    // vars.serviceHardening;
    Install.WantedBy = [ "default.target" ];
  };
}
