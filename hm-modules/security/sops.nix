{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../sops/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";

    secrets = {
      gdrive_client_id = { };
      gdrive_secret = { };
      gdrive_token = { };

      # Moved to sops/api.yaml; defaultSopsFile stays secrets.yaml.
      opencode_api_key = {
        sopsFile = ../../sops/api.yaml;
      };
      openrouter_api_key = {
        sopsFile = ../../sops/api.yaml;
      };
      gemini_api_key = {
        sopsFile = ../../sops/api.yaml;
      };
      jev_api_key = {
        sopsFile = ../../sops/api.yaml;
      };
      searx_secret_key = {
        sopsFile = ../../sops/api.yaml;
      };
      telegram_api_id = {
        sopsFile = ../../sops/api.yaml;
      };
      telegram_api_hash = {
        sopsFile = ../../sops/api.yaml;
      };
      telegram_session_string = {
        sopsFile = ../../sops/api.yaml;
      };
      antigravity_account_email = {
        sopsFile = ../../sops/api.yaml;
      };
      antigravity_account_refresh_token = {
        sopsFile = ../../sops/api.yaml;
      };
    };
  };
}
