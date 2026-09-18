# Documents and reading: pdf viewer, office, markdown preview theme.
{ vars, ... }:
{
  programs = {
    zathura.options = {
      font = "SauceCodePro Nerd Font Mono 14";
      selection-clipboard = "clipboard";
      statusbar-home-tilda = true;
      guioptions = "";
    };

    onlyoffice.settings = {
      UITheme = "theme-dark";
      editorWindowMode = false;
      maximized = true;
      titlebar = "none";
    };

    pandoc.defaults = {
      metadata.author = vars.user.fullName;
      pdf-engine = "xelatex";
      citeproc = true;
    };
  };

  xdg.configFile."glow/glow.yml".text = ''
    style: "tokyo-night"
    width: 0
    mouse: false
  '';
}
