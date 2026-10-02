# Callbacks in lua/autocmds.lua.
{ ... }:
{
  programs.nixvim.autoCmd = [
    # Ftplugins reset formatoptions, so re-apply.
    {
      event = "FileType";
      pattern = "*";
      callback.__raw = "require('autocmds').no_comment_continue";
    }
    {
      event = "FileType";
      pattern = "gitcommit";
      callback.__raw = "require('autocmds').gitcommit_opts";
    }
    {
      event = "FileType";
      pattern = "csv";
      callback.__raw = "function() require('csvview').enable() end";
    }
    {
      event = "LspAttach";
      callback.__raw = "require('autocmds').maybe_enable_inlay_hints";
    }
  ];
}
