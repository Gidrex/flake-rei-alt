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

      # Moved to secrets/api.yaml; defaultSopsFile stays secrets.yaml.
      opencode_api_key = {
        sopsFile = ../../secrets/api.yaml;
      };
      openrouter_api_key = {
        sopsFile = ../../secrets/api.yaml;
      };
      gemini_api_key = {
        sopsFile = ../../secrets/api.yaml;
      };
      jev_api_key = {
        sopsFile = ../../secrets/api.yaml;
      };
      searx_secret_key = {
        sopsFile = ../../secrets/api.yaml;
      };
      telegram_api_id = {
        sopsFile = ../../secrets/api.yaml;
      };
      telegram_api_hash = {
        sopsFile = ../../secrets/api.yaml;
      };
      telegram_session_string = {
        sopsFile = ../../secrets/api.yaml;
      };
      antigravity_account_email = {
        sopsFile = ../../secrets/api.yaml;
      };
      antigravity_account_refresh_token = {
        sopsFile = ../../secrets/api.yaml;
      };
    };
  };
}
