# Version control: git + jujutsu + lazygit.
{ config, vars, ... }:
{
  programs = {
    ssh = {
      enable = true;
      # Defaults were implicit (enableDefaultConfig); declared explicitly to add
      # the main key as the default identity. Extra hosts are listed explicitly below.
      enableDefaultConfig = false;
      settings = {
        "*" = {
          ForwardAgent = false;
          AddKeysToAgent = "no";
          Compression = false;
          ServerAliveInterval = 0;
          ServerAliveCountMax = 3;
          HashKnownHosts = false;
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
          IdentityFile = config.sops.secrets.private_ssh.path;
        };
        "gidrex-tuna" = {
          HostName = "a.2na.am";
          Port = 37064;
          User = "gidrex";
          IdentitiesOnly = true;
        };
        "github.com" = {
          HostName = "github.com";
          User = "git";
          IdentityFile = config.sops.secrets.private_ssh_github.path;
          IdentitiesOnly = true;
        };
      };
    };

    git = {
      enable = true;
      lfs.enable = true;
      includes = [
        {
          condition = "hasconfig:remote.*.url:git@github.com:*/**";
          contents.user.email = vars.github.mail;
        }
        {
          condition = "hasconfig:remote.*.url:https://github.com/**";
          contents.user.email = vars.github.mail;
        }
      ];
      settings = {
        user.name = vars.user.displayName;
        user.email = vars.user.mail;
        init.defaultBranch = "main";
        pull.rebase = true;
        rebase.autostash = true;
        rebase.autosquash = true;
        push.autoSetupRemote = true;
        commit.gpgsign = false;
        rerere.enabled = true;
        core.whitespace = "trailing-space,space-before-tab";
        core.editor = "hx";
        safe.directory = "/opt/flutter";
      };
    };

    jujutsu = {
      enable = true;
      settings = {
        user.email = vars.user.mail;
        user.name = vars.user.displayName;
        ui.color = "always";
      };
    };

    lazygit = {
      enable = true;
      settings = {
        gui.nerdFontsVersion = "3";
        git.autoFetch = false; # No startup fetch (slow)
        # Catppuccin Mocha, new-format keys (gui.theme.*).
        gui.theme = {
          activeBorderColor = [
            "#89b4fa"
            "bold"
          ];
          inactiveBorderColor = [ "#a6adc8" ];
          searchingActiveBorderColor = [
            "#89b4fa"
            "bold"
          ];
          optionsTextColor = [ "#89b4fa" ];
          selectedLineBgColor = [ "#313244" ];
          cherryPickedCommitFgColor = [ "#89b4fa" ];
          cherryPickedCommitBgColor = [ "#cba6f7" ];
          markedBaseCommitFgColor = [ "#89b4fa" ];
          markedBaseCommitBgColor = [ "#f9e2af" ];
          unstagedChangesColor = [ "#f38ba8" ];
          defaultFgColor = [ "#cdd6f4" ];
        };
      };
    };
  };
}
