# SearXNG metasearch engine as a user systemd service (localhost only).
# Secret key comes from sops-nix and is rendered into settings.yml at activation,
# so it never lands in the Nix store. Port 8888 verified free (ss -tln, 2026-09-21).
{ config, pkgs, ... }:
{
  sops.secrets.searx_secret_key = { };

  sops.templates."searxng-settings.yml" = {
    content = ''
      # 2026-09-21: startpage/ecosia consistently hit request_timeout (3.0s),
      # other general engines respond in <1s (measured via &engines=).
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
