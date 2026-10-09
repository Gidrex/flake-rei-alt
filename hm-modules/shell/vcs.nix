# Version control: git + jujutsu + lazygit.
{ vars, ... }:
{
  # Upstream catppuccin/lazygit theme is stale (gui.authorColors at the old location):
  # lazygit >= 0.44 tries to auto-migrate the read-only store file and fails on every
  # launch (LG_CONFIG_FILE points into /nix/store). Manual theme until upstream fixes it.
  catppuccin.lazygit.enable = false;

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
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
        user.signingkey = "~/.ssh/id_rsa.pub";
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
