{ ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "GeistMonoNerdFontMono";
      size = 14;
    };
    settings = {
      confirm_os_window_close = 0;
    };
  };
}
