# Local SearXNG service; secret rendered at activation, never in store.
{ config, pkgs, ... }:
{
  sops.secrets.searx_secret_key = { };

  sops.templates."searxng-settings.yml" = {
    content = ''
      # startpage/ecosia timeout (3s); other engines <1s.
      use_default_settings:
        engines:
          remove:
            - startpage
            - ecosia
      outgoing:
        request_timeout: 1.5
      server:
        bind_address: "127.0.0.1"
        port: 8888
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
