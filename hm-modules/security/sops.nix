{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";

    secrets = {
      gdrive_client_id = { };
      gdrive_secret = { };
      gdrive_token = { };
      opencode_api_key = { };
      openrouter_api_key = { };
      jev_api_key = { };
      searx_secret_key = { };
    };
  };
}
