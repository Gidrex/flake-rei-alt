# Version control: git + jujutsu + lazygit.
{ vars, ... }:
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
      };
    };
  };
}
