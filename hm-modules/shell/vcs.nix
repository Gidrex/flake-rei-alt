# Version control: git + jujutsu + lazygit.
{ vars, lib, ... }:
let
  inherit (lib) mkIf;
  inherit (builtins) pathExists;
in
{
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
        safe = mkIf (pathExists "/opt/flutter") { directory = "/opt/flutter"; };
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
        # Catppuccin Mocha (matches the global theme; lazygit has no auto-theme)
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
