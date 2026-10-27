{ config, ... }:
let
  # Moved to sops/api.yaml; defaultSopsFile stays secrets.yaml
  apiSecrets = [
    "opencode_api_key"
    "openrouter_api_key"
    "vercel_gateway_api_key"
    "searx_secret_key"
    "telegram_api_id"
    "telegram_api_hash"
    "telegram_session_string"
  ];
in
{
  sops = {
    defaultSopsFile = ../../sops/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";

    secrets = {
      gdrive_client_id = { };
      gdrive_secret = { };
      gdrive_token = { };
      private_ssh = { };
      private_ssh_github = { };
    }
    // builtins.listToAttrs (
      map (name: {
        inherit name;
        value = {
          sopsFile = ../../sops/api.yaml;
        };
      }) apiSecrets
    );
  };
}
